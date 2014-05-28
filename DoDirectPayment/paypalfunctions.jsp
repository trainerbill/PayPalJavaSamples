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
	' PayPal API Credentials
	' Replace <API_USERNAME> with your API Username
	' Replace <API_PASSWORD> with your API Password
	' Replace <API_SIGNATURE> with your Signature
	'------------------------------------
	*/
	gv_APIUserName	= "xxxxxxxxxxxxxxxx_api1.paypal.com";
	gv_APIPassword	= "xxxxxxxxxxxxxxxxx";
	gv_APISignature = "xxxxxxxxxxxxxxxxxxxxxxxxx";
	boolean bSandbox = true;
		
	/*
	Servers for NVP API
	Sandbox: https://api-3t.sandbox.paypal.com/nvp
	Live: https://api-3t.paypal.com/nvp
	*/
	 
	/*
	Redirect URLs for PayPal Login Screen
	Sandbox: https://www.sandbox.paypal.com/webscr?cmd=_express-checkout&token=XXXX
	Live: https://www.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=XXXX
	*/
 	
	if (bSandbox == true)
	{
		gv_APIEndpoint = "https://api-3t.sandbox.paypal.com/nvp";
		PAYPAL_URL = "https://www.sandbox.paypal.com/webscr?cmd=_express-checkout-mobile&token=";
	}
	else
	{
		gv_APIEndpoint = "https://api-3t.paypal.com/nvp";
		PAYPAL_URL = "https://www.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=";
	} 

	String HTTPREQUEST_PROXYSETTING_SERVER = "";
	String HTTPREQUEST_PROXYSETTING_PORT = "";
	boolean USE_PROXY = false;
	
	gv_Version	= "107.0";
	
	//WinObjHttp Request proxy settings.
	gv_ProxyServer	= HTTPREQUEST_PROXYSETTING_SERVER;
	gv_ProxyServerPort = HTTPREQUEST_PROXYSETTING_PORT;
	gv_Proxy		= 2;	//'setting for proxy activation
	gv_UseProxy		= USE_PROXY;

	
%>

<%!
	
	String gv_APIEndpoint;
	String gv_APIUserName;
	String gv_APIPassword;
	String gv_APISignature;
	String gv_BNCode;
	
	String gv_Version;
	String gv_nvpHeader;
	String gv_ProxyServer;	
	String gv_ProxyServerPort; 
	int gv_Proxy;
	boolean gv_UseProxy;
	String PAYPAL_URL;
        String nvpStr;


	

        public HashMap DirectPayment ( String paymentType, String paymentAmount,
                                String creditCardType, String creditCardNumber, String expDate, String cvv2,
                                String firstName, String lastName, String street, String city, String state, String zip, String countryCode,
                                String currencyCode, String IPAddress)
        {
                String nvpStr = "&AMT=" + paymentAmount+ "&PAYMENTACTION=" + paymentType;
                nvpStr += "&IPADDRESS=" + IPAddress;
                nvpStr += "&CREDITCARDTYPE=" + creditCardType + "&ACCT=" + creditCardNumber + "&EXPDATE=" + expDate + "&CVV2=" + cvv2;
                nvpStr += "&FIRSTNAME=" + firstName + "&LASTNAME=" + lastName + "&STREET=" + street + "&CITY=" + city + "&STATE=" + state + "&COUNTRYCODE=" + countryCode + "&ZIP=" + zip;
                nvpStr += "&ITEMAMT=8.00&TAXAMT=4.00&L_NAME0=test name 1&L_DESC0=test desc 1&L_AMT0=2.00&L_NUMBER0=123&L_QTY0=2&L_TAXAMT0=1.00&L_NAME1=test name 2&L_DESC1=test desc 2&L_AMT1=2.00&L_NUMBER1=1234&L_QTY1=2&L_TAXAMT1=1.00";
                //nvpStr += "&CURRENCYCODE=" + currencyCode;//+"&RECURRING=Y";
                System.out.println("before call"+nvpStr);
                HashMap nvp = httpcall("DoDirectPayment", nvpStr);
                System.out.println("after call"+nvp);
                return nvp;
                
        }
	
	public HashMap httpcall( String methodName, String nvpStr)
	{
		
                String version = "2.3";
                String agent = "Mozilla/4.0";
                String respText = "";
                HashMap nvp=null;
                
                String encodedData = "METHOD=" + methodName + "&VERSION=" + gv_Version + "&PWD=" + gv_APIPassword + "&USER=" + gv_APIUserName + "&SIGNATURE=" + gv_APISignature + nvpStr + "&BUTTONSOURCE=" + gv_BNCode;
                System.out.println("encodedData is :"+encodedData);
                try 
                {
                        URL postURL = new URL( gv_APIEndpoint );
                        HttpURLConnection conn = (HttpURLConnection)postURL.openConnection();
                        conn.setDoInput (true);
                        conn.setDoOutput (true);
                        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
                        conn.setRequestProperty( "User-Agent", agent );
                        
                        conn.setRequestProperty( "Content-Length", String.valueOf( encodedData.length()) );
                        System.out.println("encodedData:" + encodedData);
                        conn.setRequestMethod("POST");
                        
                        DataOutputStream output = new DataOutputStream( conn.getOutputStream());
                        output.writeBytes( encodedData );
                        output.flush();
                        output.close ();
                        
                        DataInputStream  in = new DataInputStream (conn.getInputStream()); 
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
                        return null;
                }
	}
	
	
%>
