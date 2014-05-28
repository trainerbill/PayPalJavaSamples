<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<%@ page contentType="text/html;charset=windows-1252"%>
<html>
	 <head>
		<meta http-equiv="Content-Type" content="text/html; charset=windows-1252"/>
		<title>iframe_index</title>
	  <%@include file="paypalfunctions.jsp" %>
	  <%

		/*
		'-------------------------------------------
		' The paymentAmount is the total value of 
		' the shopping cart, that was set 
		' earlier in a session variable 
		' by the shopping cart page
		'-------------------------------------------
		*/

		String paymentAmount = "20.00";//(String) session.getAttribute("Payment_Amount");
		String currencyCodeType = "USD";
		session.setAttribute("currencyCodeType", currencyCodeType);
		String paymentType = "Sale";
		session.setAttribute("paymentType", paymentType);
		String firstName = "Pavana"; //request.getParameter("firstname");
		String lastName = "D"; //request.getParameter("lastname");
		String street = "123 Main Street"; //request.getParameter("street");
		String city = "Omaha"; //request.getParameter("city");
		String state = "NE"; //request.getParameter("state");
		String zip = "68182"; //request.getParameter("zip");
		String countryCode = "US"; //request.getParameter("country");
		String orderdescription = "test order"; //request.getParameter("desc");
		
		HashMap nvp = getSecureToken (paymentType, paymentAmount, firstName, lastName, street, city, state, zip, countryCode, currencyCodeType, orderdescription);
		String securetoken = nvp.get("SECURETOKEN").toString();
		String securetokenid = nvp.get("SECURETOKENID").toString();
		
	%>

	 </head>
	 <body>
	 
			<form method='post' action='https://payflowlink.paypal.com/' target='test'>
				<input type='hidden' name='SECURETOKEN' value="<%= securetoken %>"/>
				<input type='hidden' name='SECURETOKENID' value="<%= securetokenid %>" />
				<input type='hidden' name='MODE' value='test' />
				<input type='image' name='submit' id="submitBtn" src='https://www.paypal.com/en_US/i/btn/btn_dg_pay_w_paypal.gif' border='0' align='top' alt='Check out with PayPal'/>
			</form>
			
			<iframe src="iframe_index.jsp" frameborder="0" name="test" id="test" width=1200 height=800></iframe>

	 </body>
</html>