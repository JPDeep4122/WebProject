package com.dienmay.config;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilderFactory;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.apache.jasper.servlet.JasperInitializer;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.web.servlet.ServletContextInitializer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.w3c.dom.Element;

import jakarta.servlet.ServletException;

@Configuration(proxyBeanMethods = false)
@ConditionalOnProperty(name = "app.jsp.precompiled", havingValue = "true")
public class PrecompiledJspConfiguration {
    private static final Logger log = LoggerFactory.getLogger(PrecompiledJspConfiguration.class);

    @Bean
    ServletContextInitializer precompiledJspServlets() {
        // Embedded Tomcat needs explicit registration of JspC's servlet mappings.
        return context -> {
            // Keep JSP runtime services (JspFactory, JSTL listeners and tag cache)
            // even though the on-demand compiling JspServlet is disabled.
            new JasperInitializer().onStartup(Set.of(), context);
            try (var source = new ClassPathResource("META-INF/jsp-servlets.xml").getInputStream()) {
                var factory = DocumentBuilderFactory.newInstance();
                factory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
                factory.setAttribute(XMLConstants.ACCESS_EXTERNAL_DTD, "");
                factory.setAttribute(XMLConstants.ACCESS_EXTERNAL_SCHEMA, "");
                var document = factory.newDocumentBuilder().parse(source);
                Map<String, jakarta.servlet.ServletRegistration.Dynamic> registrations = new HashMap<>();
                var servlets = document.getElementsByTagName("servlet");
                for (int index = 0; index < servlets.getLength(); index++) {
                    Element servlet = (Element) servlets.item(index);
                    String name = text(servlet, "servlet-name");
                    String className = text(servlet, "servlet-class");
                    if (getClass().getClassLoader().getResource(className.replace('.', '/') + ".class") == null) {
                        throw new ServletException("Missing precompiled JSP class: " + className);
                    }
                    var registration = context.addServlet(name, className);
                    if (registration == null) {
                        throw new ServletException("Duplicate precompiled JSP servlet: " + name);
                    }
                    registrations.put(name, registration);
                }
                var mappings = document.getElementsByTagName("servlet-mapping");
                for (int index = 0; index < mappings.getLength(); index++) {
                    Element mapping = (Element) mappings.item(index);
                    String path = text(mapping, "url-pattern");
                    var registration = registrations.get(text(mapping, "servlet-name"));
                    if (registration == null || !path.startsWith("/WEB-INF/views/")
                            || !registration.addMapping(path).isEmpty()) {
                        throw new ServletException("Invalid precompiled JSP mapping: " + path);
                    }
                }
                if (registrations.isEmpty()) {
                    throw new ServletException("No precompiled JSP servlets found");
                }
                log.info("Registered {} precompiled JSP servlets", registrations.size());
            } catch (ServletException ex) {
                throw ex;
            } catch (Exception ex) {
                throw new ServletException("Could not register precompiled JSPs; run Maven package first", ex);
            }
        };
    }

    private static String text(Element element, String name) {
        return element.getElementsByTagName(name).item(0).getTextContent().trim();
    }
}
