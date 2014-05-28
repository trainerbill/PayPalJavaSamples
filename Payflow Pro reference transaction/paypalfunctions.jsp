<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<%@ page contentType="text/html;charset=windows-1252"%>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=windows-1252"/>
    <title>paypalfunctions</title>
  </head>
  <body>
  
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

	gv_APIUser	="xxxxxxxx";
	gv_APIPassword	="xxxxxx";
	gv_APIVendor = "xxxxxx";
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

	public HashMap DirectPayment( String paymentType, String paymentAmount, String creditCardType, String creditCardNumber, String expDate, String cvv2, String firstName, String lastName, String street, String city, String state, String zip, String countryCode, String currencyCode, String orderdescription, String IPAddress )
	{
		/* Construct the parameter string that describes the credit card payment */
		String nvpstr = "&TENDER=C";
		if (paymentType.equalsIgnoreCase("Sale"))
		{
			nvpstr = nvpstr + "&TRXTYPE=S";
		}
		else if (paymentType.equalsIgnoreCase("Authorization"))
		{
			nvpstr = nvpstr + "&TRXTYPE=A";
		}
		else /* default to sale */
		{
			nvpstr = nvpstr + "&TRXTYPE=S";
		}

	    /* requires at least Java 5 */
		UUID uid = UUID.randomUUID();
		nvpstr = nvpstr + "&ACCT=" + creditCardNumber + "&EXPDATE=" + expDate +"&CVV2="+ cvv2 + "&ACCTTYPE=" + creditCardType;
		nvpstr = nvpstr + "&AMT=" + paymentAmount + "&CURRENCYCODE=" + currencyCode;
		nvpstr = nvpstr + "&FIRSTNAME=" + firstName + "&LASTNAME=" + lastName + "&STREET=" + street + "&CITY=" + city;
		nvpstr = nvpstr + "&STATE=" + state + "&ZIP=" + zip + "&COUNTRY=" + countryCode;
		nvpstr = nvpstr + "&INVNUM=" + uid.toString() + "&ORDERDESC=" + orderdescription+"&ITEMAMT="+ paymentAmount;
		nvpstr = nvpstr + "&VERBOSITY=HIGH";
        nvpstr = nvpstr + "&Email=test@test.com&Ponum="+uid.toString()+"&PhoneNum=6365414705";
                
		/*
		'-------------------------------------------------------------------------------------------
		' Make the call to Payflow to finalize payment
		' If an error occured, show the resulting errors
		'-------------------------------------------------------------------------------------------
		*/
 		HashMap nvp = httpcall(nvpstr,uid.toString());
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
	public HashMap DoDelayedCapture( String billingID)
	{
        UUID uid = UUID.randomUUID();
		String nvpstr  = "&ORIGID=" + billingID +"&TRXTYPE=D&TENDER=C&CURRENCY=USD";
		nvpstr = nvpstr + "&VERBOSITY=HIGH";		
		HashMap nvp = httpcall(nvpstr,uid.toString());
		return nvp;
	}
	public HashMap DoRefund( String transactionId)
	{
        UUID uid = UUID.randomUUID();
		String nvpstr  = "&ORIGID=" + transactionId +"&TRXTYPE=C&TENDER=C&CURRENCY=USD";
		nvpstr = nvpstr + "&VERBOSITY=HIGH";		
		HashMap nvp = httpcall(nvpstr,uid.toString());
		return nvp;
	}
	public HashMap DoRefundPartial( String transactionId, String amt)
	{
        UUID uid = UUID.randomUUID();
		String nvpstr  = "&ORIGID=" + transactionId +"&TRXTYPE=C&TENDER=C&CURRENCY=USD&AMT="+amt;
		nvpstr = nvpstr + "&VERBOSITY=HIGH";		
		HashMap nvp = httpcall(nvpstr,uid.toString());
		return nvp;
	}
	 public HashMap DoReferenceTransaction( String billingID, String paymentamount)
	{
        UUID uid = UUID.randomUUID();
		String nvpstr  = "&ORIGID=" + billingID +"&TRXTYPE=S&TENDER=C&CURRENCY=USD&AMT="+paymentamount;
		nvpstr = nvpstr + "&VERBOSITY=HIGH";		
		HashMap nvp = httpcall(nvpstr,uid.toString());
		return nvp;
	}
        
%>

  
  </body>
</html>