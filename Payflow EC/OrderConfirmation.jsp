<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<%@ page contentType="text/html;charset=windows-1252"%>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=windows-1252"/>
    <title>OrderConfirmation</title>
  </head>
  <body>
  <%
/*==================================================================
 Payflow Express Checkout Call
 ===================================================================
*/
String token = request.getParameter("mytoken");
session.setAttribute("TOKEN",token);
if ( token != null)
{

%>
<%@include file="paypalfunctions.jsp" %>
<% 
	/*
	'------------------------------------
	' Get the token parameter value stored in the session 
	' from the previous SetExpressCheckout call
	'------------------------------------
	*/
	//String token =  session.getAttribute("TOKEN");

	/*
	'------------------------------------
	' The paymentAmount is the total value of 
	' the shopping cart, that was set 
	' earlier in a session variable 
	' by the shopping cart page
	'------------------------------------
	*/

	String finalPaymentAmount =  session.getAttribute("Payment_Amount").toString();

        /*
	'------------------------------------
	' Calls DoExpressCheckoutPayment
	'
	' The ConfirmPayment function is defined in the file PayPalFunctions.jsp,
	' that is included at the top of this file.
	'-------------------------------------------------
	*/

	HashMap nvp = ConfirmPayment (finalPaymentAmount, session, request );

        String strAck = nvp.get("RESULT").toString();
	if(strAck !=null && strAck.equalsIgnoreCase("0"))
	{
		/*
		'********************************************************************************************************************
		'
		' THE PARTNER SHOULD SAVE THE KEY TRANSACTION RELATED INFORMATION LIKE 
		'                    transactionId & orderTime 
		'  IN THEIR OWN  DATABASE
		' AND THE REST OF THE INFORMATION CAN BE USED TO UNDERSTAND THE STATUS OF THE PAYMENT 
		'
		'********************************************************************************************************************
		*/

		String transactionId	        = nvp.get("PPREF").toString(); // ' Unique transaction ID of the payment. 
		String paymentType		= nvp.get("PAYMENTTYPE").toString();  //' Returns "instant" if the payment is instant or "echeck" if the payment is delayed.
		//String amt			= nvp.get("AMT").toString();  //' The final amount charged, including any shipping and taxes from your Merchant Profile.
		String feeAmt			= nvp.get("FEEAMT").toString();  //' PayPal fee amount charged for the transaction
		//String taxAmt			= nvp.get("TAXAMT").toString();  //' Tax charged on the transaction.
		String pnref			= nvp.get("PNREF").toString();  //' PayPal Manager Transaction ID that is used by PayPal to identify this transaction in PayPal Manager reports.

		/*
		'The reason the payment is pending:
		'  none: No pending reason 
		'  address: The payment is pending because your customer did not include a confirmed shipping address and your Payment Receiving Preferences is set such that you want to manually accept or deny each of these payments. To change your preference, go to the Preferences section of your Profile. 
		'  echeck: The payment is pending because it was made by an eCheck that has not yet cleared. 
		'  intl: The payment is pending because you hold a non-U.S. account and do not have a withdrawal mechanism. You must manually accept or deny this payment from your Account Overview. 		
		'  multi-currency: You do not have a balance in the currency sent, and you do not have your Payment Receiving Preferences set to automatically convert and accept this payment. You must manually accept or deny this payment. 
		'  verify: The payment is pending because you are not yet verified. You must verify your account before you can accept this payment. 
		'  other: The payment is pending for a reason other than those listed above. For more information, contact PayPal customer service. 
		*/
		
		String pendingReason	= nvp.get("PENDINGREASON").toString();   

%>
Order Success !!!
<%
	}
	else
	{  
		// Display a user friendly Error on the page using any of the following error information returned by PayPal
		
		// See Table 4.2 and 4.3 in http://www.paypal.com/en_US/pdf/PayflowPro_Guide.pdf for a list of RESULT values (error codes)
		//Display a user friendly Error on the page using any of the following error information returned by Payflow
		String ErrorCode = strAck;
		String ErrorMsg = nvp.get("RESPMSG").toString();
	}
}
else
{
    System.out.println("my token is null");
}
		
%>
  
  
  </body>
</html>