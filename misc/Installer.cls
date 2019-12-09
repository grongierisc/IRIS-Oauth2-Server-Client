Include %occInclude

Class OAuth2.Installer
{

XData Install [ XMLNamespace = INSTALLER ]
{
<Manifest>

    <Log Text="Version d'IRIS ${VERSION}" Level="0"/>
    <!-- Check if NameSpace variable is valued -->
    <If Condition='$L("${NAMESPACE}")=0'>
        <Error Status="$$$NamespaceDoesNotExist">
            <Arg Value="${NAMESPACE}"/>
        </Error>
    </If>

    <!-- If exist do nothing, else create namespace -->
    <If Condition='(##class(Config.Namespaces).Exists("${NAMESPACE}")=0)'>
        <Log Text="Creating namespace ${NAMESPACE}" Level="0"/>

        <!-- temp hack, our data database goes into pre-existing and persisted USER database -->
        <Namespace Name="${NAMESPACE}" Create="yes" Code="${NAMESPACE}_SRC" Ensemble="1" Data="${NAMESPACE}_DATA">
            <Configuration>
                <!-- sources are not presisted but kept in the container/image (done on purpose) -->
                <Database Name="${NAMESPACE}_SRC" Dir="${MGRDIR}/${NAMESPACE}_SRC" Create="yes" Resource="%DB_${NAMESPACE}_SRC"/>
                <Database Name="${NAMESPACE}_DATA" Dir="${MGRDIR}/${NAMESPACE}_DATA" Create="yes" Resource="%DB_${NAMESPACE}_DATA"/>
            
            </Configuration>
        
            <!-- Need to create equivalent value of Default application for [NAMESPACE]: /csp/healthshare/[namespace], see Edit Web application window in portal -->
            <CSPApplication Url="/csp/healthshare/${NAMESPACE}" Directory="${CSPDIR}/${NAMESPACE}" AuthenticationMethods="64" IsNamespaceDefault="true" />

        </Namespace>


    </If>

</Manifest>
}

ClassMethod setup(ByRef pVars, pLogLevel As %Integer = 0, pInstaller As %Installer.Installer) As %Status [ CodeMode = objectgenerator, Internal ]
{
	
     Quit ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "Install")
}

ClassMethod CreateOauth2Server() As %Status
{
	set currentNS = $Namespace
    zn "%SYS"
    Set tSC = $$$OK

	Set sys = ##class(OAuth2.Server.Configuration).%New()
	

	Set sys.IssuerEndpoint.Host = "localhost"
	Set sys.IssuerEndpoint.Port = ""
	Set sys.IssuerEndpoint.Prefix = ""

	Set sys.AccessTokenInterval = 3600
	Set sys.AuthorizationCodeInterval = 60
	Set sys.RefreshTokenInterval = 86400
	Set sys.SessionInterval = 86400
	Set sys.ClientSecretInterval = 0
	Do sys.SupportedScopes.Clear()

	Do sys.SupportedScopes.SetAt(1, "openid")
	Do sys.SupportedScopes.SetAt(2, "profile")
	Do sys.SupportedScopes.SetAt(3, "scope1")
	Do sys.SupportedScopes.SetAt(4, "scope2")

	Set sys.Description = ""
	Set sys.DefaultScope = ""
	Set sys.AllowUnsupportedScope = 0
	Set sys.AudRequired = 0
	Set sys.SupportSession = 1
	Set sys.ReturnRefreshToken = ""
	Set sys.SupportedGrantTypes = "AIPCJ"
	Set sys.CustomizationRoles = "%DB_IRISSYS,%Manager"
	Set sys.CustomizationNamespace = "%SYS"
	Set sys.AuthenticateClass = "%OAuth2.Server.Authenticate"
	Set sys.SessionClass = "OAuth2.Server.Session"
	Set sys.ValidateUserClass = "%OAuth2.Server.Validate"
	Set sys.GenerateTokenClass = "%OAuth2.Server.JWT"
	Set sys.ServerCredentials = ""
	Set sys.ServerPassword = ""
	Set sys.SigningAlgorithm = "RS256"
	Set sys.EncryptionAlgorithm = "A128CBC-HS256"
	Set sys.KeyAlgorithm = "RSA1_5"
	Set sys.SSLConfiguration = "SSL"
	Set tSC = sys.Save()

	zn currentNS

    Quit tSC
}

ClassMethod CreateSSLConfig() As %Status
{
	set currentNS = $Namespace
    zn "%SYS"
    Set tSC = $$$OK

    Set sys = ##class(Security.SSLConfigs).%New()
	Set sys.Name = "SSL"
    Set sys.VerifyPeer = 0
    Set sys.Type = 0
    Set sys.Enabled = 1
	Set tSC = sys.%Save()

	zn currentNS

    Quit tSC
}

ClassMethod CreateServerDefinitionForClient()
{
	set currentNS = $Namespace
	zn "%SYS"

    Set tSC = $$$OK
		/*
		
		Set sys.IssuerEndpoint = "https://localhost/oauth2"
		Set sys.SSLConfiguration = "SSL"
		Set sys.ServerCredentials = ""
		Set sys.InitialAccessToken = ""
		Set sys.IsDiscovery = 1

		Set tSC=##class(OAuth2.ServerDefinition).GetServerMetadata("http://localhost/oauth2","",.metadata)

		Set sys.Metadata = metadata

		Set tSC = sys.%Save()
		*/
	
    Set sys = ##class(OAuth2.ServerDefinition).%New()
	Set sys.IssuerEndpoint = "https://localhost/oauth2"
	Set sys.InitialAccessToken = ""
	Set sys.SSLConfiguration = "SSL"
	Set sys.Metadata."authorization_endpoint" = ""
	Set sys.Metadata."token_endpoint" = ""
	Set sys.Metadata."userinfo_endpoint" = ""
	Set sys.Metadata."introspection_endpoint" = ""
	Set sys.Metadata."revocation_endpoint" = ""
	Set sys.ServerCredentials = ""
	Set sys.IsDiscovery = 1
	Do sys.%Save()
	

	zn currentNS

    Quit tSC
}

ClassMethod CreateClient()
{
	set currentNS = $Namespace
	zn "%SYS"

    Set tSC = $$$OK

	Set tClientServer = ##class(OAuth2.Server.Client).%New()
	Set tClientServer.SupportedGrantTypes = "AIPC"
	Set tClientServer.Name = "Client2"
	Do tClientServer.RedirectURL.Insert("https://localhost/csp/sys/oauth2/OAuth2.Response.cls")
	Set tClientServer.ClientType = "confidential"
	Set tClientServer.Metadata."jwks_uri" = "https://localhost/csp/sys/oauth2/OAuth2.JWTServer.cls?client_name=Client"
	Set tClientServer.Metadata."redirect_uris" = $lb("https://localhost/csp/sys/oauth2/OAuth2.Response.cls")
	Set tClientServer.Metadata."registration_client_uri" = "https://localhost/oauth2/register?client_id="_tClientServer.ClientId
	Do ##class(%OAuth2.JWKS).AddRSA(,.private,.public)
	Do tClientServer.Save()


	Set sys = ##class(OAuth2.Client).%New()
	Set sys.ApplicationName = "Client"
	
	Set sys.ServerDefinition = 2
	Set sys.Enabled = 1
	Set sys.ClientType = "confidential"
	Set sys.Description = ""
	Set sys.SSLConfiguration = "SSL"
	Set sys.RedirectionEndpoint.UseSSL = 1
	Set sys.RedirectionEndpoint.Host = "localhost"
	Set sys.RedirectionEndpoint.Port = ""
	Set sys.RedirectionEndpoint.Prefix = ""
	Set sys.DefaultScope = ""
	Set sys.Metadata."token_endpoint_auth_method" = "client_secret_basic"
	Set sys.Metadata."grant_types" = $lb("authorization_code","implicit","password","client_credentials","refresh_token") //jwt_authorization
	Set sys.Metadata."client_name" = "Client"
	Set sys.Metadata."logo_uri" = ""
	Set sys.Metadata."client_uri" = ""
	Set sys.Metadata."policy_uri" = ""
	Set sys.Metadata."tos_uri" = ""
	Set sys.ClientId = tClientServer.ClientId
	Set sys.ClientSecret = tClientServer.ClientSecret
	Set sys.ClientCredentials = ""
	Set sys.ClientPassword = ""

	Set sys.Metadata."jwks_uri" = "https://localhost/csp/sys/oauth2/OAuth2.JWTServer.cls?client_name=Client"
	Set sys.Metadata."redirect_uris" = $lb("https://localhost/csp/sys/oauth2/OAuth2.Response.cls")
	Set sys.Metadata."token_endpoint_auth_signing_alg" = ""
	Set sys.Metadata."id_token_signed_response_alg" = ""
	Set sys.Metadata."id_token_encrypted_response_enc" = ""
	Set sys.Metadata."id_token_encrypted_response_alg" = ""
	Set sys.Metadata."userinfo_signed_response_alg" = ""
	Set sys.Metadata."userinfo_encrypted_response_enc" = ""
	Set sys.Metadata."userinfo_encrypted_response_alg" = ""
	Set sys.Metadata."access_token_signed_response_alg" = ""
	Set sys.Metadata."access_token_encrypted_response_enc" = ""
	Set sys.Metadata."access_token_encrypted_response_alg" = ""
	Set sys.Metadata."request_object_signing_alg" = ""
	Set sys.Metadata."request_object_encryption_enc" = ""
	Set sys.Metadata."request_object_encryption_alg" = ""

	Set sys.Metadata.contacts = ""
	Set sys.Metadata."default_max_age" = ""

	zn currentNS

    Quit tSC
}

}
