<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<%@ page contentType="text/html;charset=windows-1252"%>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=windows-1252"/>
    <title>paypalfunctions</title>
  </head>
  <body>
  
  <%
	/*==================================================================
	 Payflow Express Checkout Module
	 ===================================================================
	--------------------------------------------------------------------
	*/
%>

<%@ page language="java" %>
<%@ page language="java" import="java.net.URLDecoder.*" %> 
<%@ page language="java" import="java.util.*" %> 
<%@ page language="java" import="java.util.HashMap" %> 
<%@ page language="java" import="java.util.StringTokenizer.*" %> 
<%@ page language="java" import="java.io.*" %> 
<%@ page language="java" import="java.net.*" %> 
<%@ page language="java" import="javax.net.ssl.*" %> 
 
<%
	/*
	'------------------------------------
	' Payflow Credentials 
	'------------------------------------
	*/

	gv_APIUser	= "XXXXX";
	gv_APIPassword	= "XXXXXX";
	gv_APIVendor = "XXXXXXX";
	gv_APIPartner = "PayPal";
	gv_Env = "pilot";
		
	if (gv_Env == "pilot")
	{
		gv_APIEndpoint = "https://pilot-payflowpro.paypal.com";
		PAYPAL_URL = "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=";
	}
	else
	{
		gv_APIEndpoint = "https://payflowpro.paypal.com";
		PAYPAL_URL = "https://www.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=";
	} 

	String HTTPREQUEST_PROXYSETTING_SERVER = "";
	String HTTPREQUEST_PROXYSETTING_PORT = "";
	boolean USE_PROXY = false;
	
	//WinObjHttp Request proxy settings.
	gv_ProxyServer	= HTTPREQUEST_PROXYSETTING_SERVER;
	gv_ProxyServerPort = HTTPREQUEST_PROXYSETTING_PORT;
	gv_Proxy		= 2;	//'setting for proxy activation
	gv_UseProxy		= USE_PROXY;

	
%>

<%!
        String gv_APIEndpoint;
	String gv_APIUser;
	String gv_APIPassword;
	String gv_APIVendor;
	String gv_APIPartner;
	String gv_BNCode;
	String gv_Env;

	String gv_nvpHeader;
	String gv_ProxyServer;	
	String gv_ProxyServerPort; 
	int gv_Proxy;
	boolean gv_UseProxy;
	String PAYPAL_URL;
	String Env;
        String sessionuuid;

	public HashMap CallShortcutExpressCheckout( String paymentAmount, String currencyCodeType, String paymentType, 
												String returnURL, String cancelURL, HttpSession session)
	{
		
		session.setAttribute("paymentType", paymentType);
		session.setAttribute("currencyCodeType", currencyCodeType);

                String nvpstr = "&TENDER=P&ACTION=S";
		if ("Authorization" == paymentType)
		{
			nvpstr = nvpstr + "&TRXTYPE=A";
		}
		else /* sale */
		{
			nvpstr = nvpstr + "&TRXTYPE=S";
		}
		
		nvpstr = nvpstr + "&AMT=" + paymentAmount;
		nvpstr = nvpstr + "&CURRENCY=" + currencyCodeType;
		nvpstr = nvpstr + "&CANCELURL=" + cancelURL;
		nvpstr = nvpstr + "&RETURNURL=" + returnURL;
                nvpstr = nvpstr + "&L_NAME0=" + "Test Item 1";
                nvpstr = nvpstr + "&L_DESC0=" + "Testing";
                nvpstr = nvpstr + "&L_COST0=" + "50.00";
                nvpstr = nvpstr + "&L_QTY0=" + "1";
                nvpstr = nvpstr + "&ITEMAMT=" + "50.00";
		
		UUID uid = UUID.randomUUID();
		System.out.println("Passing string to Set EC : "+ nvpstr +" uid is : " + uid.toString());
                session.setAttribute("unique_id", uid.toString());	    
                HashMap nvp = httpcall(nvpstr, uid.toString());
		String strAck = nvp.get("RESULT").toString();
                
		if(strAck !=null && strAck.equalsIgnoreCase("0"))
		{
                session.setAttribute("TOKEN", nvp.get("TOKEN").toString());
		}
		
		return nvp;
	}

	public HashMap GetShippingDetails(String token, HttpSession session)
	{
		/* 
		Build a second API request to Payflow, using the token as the
		ID to get the details on the payment authorization
		*/
	    String paymentType = (String )session.getAttribute("paymentType");

	    String nvpstr = "&TOKEN=" + token + "&TENDER=P&ACTION=G";
		if ("Authorization" == paymentType)
		{
			nvpstr = nvpstr + "&TRXTYPE=A";
		}
		else /* sale */
		{
			nvpstr = nvpstr + "&TRXTYPE=S";
		}

	   /*
	    Make the API call and store the results in an array.  If the
		call was a success, show the authorization details, and provide
		an action to complete the payment.  If failed, show the error
		*/
		
		/* requires at least Java 5 */
		UUID uid = UUID.randomUUID();
		
		HashMap nvp = httpcall(nvpstr,uid.toString());
		String strAck = nvp.get("RESULT").toString();
	    if(strAck != null && strAck.equalsIgnoreCase("0"))
		{
			session.setAttribute("PAYERID", nvp.get("PAYERID").toString());
		}			
		return nvp;
	}
	
	public HashMap ConfirmPayment(String finalPaymentAmount, HttpSession session, HttpServletRequest request )
	{

		/*
		'----------------------------------------------------------------------------
		'----	Use the values stored in the session from the previous SetEC call	
		'----------------------------------------------------------------------------
		*/

		String token 			=  session.getAttribute("TOKEN").toString();

		String currencyCodeType	        =  session.getAttribute("currencyCodeType").toString();

                String paymentType 		=  session.getAttribute("paymentType").toString();

		String payerID 			=  session.getAttribute("PAYERID").toString();

                String serverName 		=  request.getServerName();

		String nvpstr = "&TOKEN=" + token + "&TENDER=P&ACTION=D";
		if (paymentType.equalsIgnoreCase("Authorization"))
		{
			nvpstr = nvpstr + "&TRXTYPE=A";
		}
		else /* sale */
		{
			nvpstr = nvpstr + "&TRXTYPE=S";
		}
		
		nvpstr = nvpstr + "&PAYERID=" + payerID + "&AMT=" + finalPaymentAmount;
		nvpstr = nvpstr + "&CURRENCY=" + currencyCodeType + "&IPADDRESS=" + serverName;

	    /* 
		Make the call to Payflow to finalize payment
		If an error occured, show the resulting errors
	    */
	    
	    
	    if (session.getAttribute("unique_id").toString().equalsIgnoreCase(""))
	    {
	    	/* requires at least Java 5 */
			UUID uid = UUID.randomUUID();
			sessionuuid = uid.toString();
			session.setAttribute("unique_id",sessionuuid);
	    }
            else
            {
                sessionuuid = session.getAttribute("unique_id").toString();
                
            }
		
		HashMap nvp = httpcall(nvpstr,sessionuuid);
		
		return nvp;
	}

	
	
	/* ********************************************************************************
	  * httpcall: Function to perform the Payflow call
	  * 	@nvpStr is nvp string.
	  * returns a NVP string containing the response from the server.
	******************************************************************************** */
	public HashMap httpcall( String nvpStr, String unique_id )
	{

		String agent = "Mozilla/4.0";
		String respText = "";
		HashMap nvp = null;

		String encodedData = "PWD=" + gv_APIPassword + "&USER=" + gv_APIUser + "&VENDOR=" + gv_APIVendor + "&PARTNER=" + gv_APIPartner + nvpStr + "&BUTTONSOURCE=" + gv_BNCode;

		try 
		{
			URL postURL = new URL( gv_APIEndpoint );
			HttpURLConnection conn = (HttpURLConnection)postURL.openConnection();

			// Set connection parameters. We need to perform input and output, 
	        // so set both as true. 
			conn.setDoInput (true);
			conn.setDoOutput (true);

			// Set the content type we are POSTing.
			conn.setRequestProperty("Content-Type", "text/namevalue");
			conn.setRequestProperty("User-Agent", agent );

			conn.setRequestProperty("Content-Length", String.valueOf(encodedData.length()));
			conn.setRequestMethod("POST");

			// set the host header
			if (gv_Env == "pilot") 
			{
				conn.setRequestProperty("Host", "pilot-payflowpro.paypal.com");
			}
			else
			{
				conn.setRequestProperty("Host", "payflowpro.paypal.com");
			}

			conn.setRequestProperty("X-VPS-CLIENT-TIMEOUT", "45");
			conn.setRequestProperty("X-VPS-REQUEST-ID", unique_id);
				
	        // get the output stream to POST to. 
			DataOutputStream output = new DataOutputStream(conn.getOutputStream());
			output.writeBytes( encodedData );
			output.flush();
	        output.close();
			
			// Read input from the input stream.
			DataInputStream  in = new DataInputStream(conn.getInputStream()); 
	    	int rc = conn.getResponseCode();
			if ( rc != -1)
			{
				BufferedReader is = new BufferedReader(new InputStreamReader( conn.getInputStream()));
				String _line = null;
				while(((_line = is.readLine()) !=null))
				{
					respText = respText + _line;
				}			
				nvp = deformatNVP( respText );
			}
			return nvp;
		}
		catch( IOException e )
		{
			// handle the error here
			return null;
		}
                
	}
	
	/* ********************************************************************************
	  * deformatNVP: Function to break the NVP string into a HashMap
	  * 	pPayLoad is the NVP string.
	  * returns a HashMap object containing all the name value pairs of the string.
	******************************************************************************** */
	public HashMap deformatNVP( String pPayload )
	{
		HashMap nvp = new HashMap(); 
		StringTokenizer stTok = new StringTokenizer( pPayload, "&");
		while (stTok.hasMoreTokens())
		{
			StringTokenizer stInternalTokenizer = new StringTokenizer( stTok.nextToken(), "=");
			if (stInternalTokenizer.countTokens() == 2)
			{
				String key = URLDecoder.decode( stInternalTokenizer.nextToken());
				String value = URLDecoder.decode( stInternalTokenizer.nextToken());
				nvp.put( key.toUpperCase(), value );
			}
		}
		return nvp;
	}
	
	/*********************************************************************************
	  * ReDirectURL: Function to redirect the user to the PayPal site
	  * 	token is the parameter that was returned by PayPal
	  * returns a HashMap object containing all the name value pairs of the string.
	*********************************************************************************/
	public void ReDirectURL(String token, HttpServletResponse response)
	{
                System.out.println("in redirect call with token : " + token);
		String payPalURL = PAYPAL_URL + token; 
		System.out.println("url is : " + payPalURL);
		//response.sendRedirect( payPalURL );
		response.setStatus(302);
		response.setHeader( "Location", payPalURL );
		response.setHeader( "Connection", "close" );
	}
        
        
	
%>

  
  </body>
</html>