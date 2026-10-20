<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<meta name="_csrf"
      content="<c:out value='${_csrf.token}'/>">

<meta name="_csrf_header"
      content="<c:out value='${_csrf.headerName}'/>">

<script src="${pageContext.request.contextPath}/js/security.js"></script>