Class Web.OAUTH2.demoResourceWithTokenAuth Extends %CSP.Page
{

ClassMethod OnPage() As %Status
{
    // access token authentication is performed by means of Delegated authentication!
    // no need to do it, again, here

    // This is a dummy resource server which just gets the access token from the request and
    // uses the introspection endpoint to ensure that the access token is valid.
    // Normally the response would not be security related, but would contain some interesting
    // data based on the request parameters.
    w "<p><h3>Hello from Cach&eacute; server: <i>/api/close/Web.OAUTH2.demoResourceWithTokenAuth</i> application!</h3>"
    w "<p>running code as <b>$username = "_$username_"</b> with following <b>$roles = "_$roles_"</b> at node <b>"_$p($zu(86),"*",2)_"</b>."
    Quit $$$OK
}

}
