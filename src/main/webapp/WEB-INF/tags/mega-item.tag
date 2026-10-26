<%@ tag body-content="empty" pageEncoding="UTF-8" %>
<%@ attribute name="label" required="true" type="java.lang.String" %>
<%@ attribute name="keyword" required="true" type="java.lang.String" %>
<%@ attribute name="image" required="true" type="java.lang.String" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:url var="itemUrl" value="/products">
    <c:param name="keyword" value="${keyword}"/>
</c:url>
<c:url var="imageUrl" value="/images/categories/${image}"/>

<a class="mega-sub-item" href="${fn:escapeXml(itemUrl)}">
    <img class="mega-sub-image"
         src="${fn:escapeXml(imageUrl)}"
         width="96" height="96"
         alt="" loading="lazy" decoding="async">
    <span><c:out value="${label}"/></span>
</a>