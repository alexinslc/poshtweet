<# 
This function allows you to tweet from PowerShell.

It DOES require you setup your own application at http://dev.twitter.com to get the following required items.
* Consumer Key   
* Consumer Secret
* OAuth Token
* OAuth Token Secret
You will need to insert them on the lines below.

Usage: tweet -Message "Hello Twitter! from #poshtweet!"

#>

function tweet() {
    param (
    [Parameter(Mandatory=$true)][string]$Message
    )
    [Reflection.Assembly]::LoadWithPartialName("System.Security")
    [Reflection.Assembly]::LoadWithPartialName("System.Net")  
    
    # Set your OAuth variables and such.
    $status = [System.Uri]::EscapeDataString($Message);  
    $oauth_consumer_key = "INSERT YOUR CONSUMER API KEY HERE";  
    $oauth_consumer_secret = "INSERT YOUR CONSUMER API SECRET HERE";  
    $oauth_token = "INSERT YOUR TOKEN HERE";  
    $oauth_token_secret = "INSERT YOUR TOKEN SECRET HERE";    
    $random = New-Object -type Random
    $oauth_nonce = $random.Next()
    $culture = New-Object System.Globalization.CultureInfo("en-US")
    $ts = [System.DateTime]::UtcNow - [System.DateTime]::ParseExact("01/01/1970", "dd/MM/yyyy", $null)
    $oauth_timestamp = [System.Convert]::ToInt64($ts.TotalSeconds).ToString();  
    
    # Build base signature
    $signature = "POST&";  
    $signature += [System.Uri]::EscapeDataString("https://api.twitter.com/1.1/statuses/update.json") + "&";  
    $signature += [System.Uri]::EscapeDataString("oauth_consumer_key=" + $oauth_consumer_key + "&");  
    $signature += [System.Uri]::EscapeDataString("oauth_nonce=" + $oauth_nonce + "&");   
    $signature += [System.Uri]::EscapeDataString("oauth_signature_method=HMAC-SHA1&");  
    $signature += [System.Uri]::EscapeDataString("oauth_timestamp=" + $oauth_timestamp + "&");  
    $signature += [System.Uri]::EscapeDataString("oauth_token=" + $oauth_token + "&");  
    $signature += [System.Uri]::EscapeDataString("oauth_version=1.0&");  
    $signature += [System.Uri]::EscapeDataString("status=" + $status);  
    $signature_key = [System.Uri]::EscapeDataString($oauth_consumer_secret) + "&" + [System.Uri]::EscapeDataString($oauth_token_secret);  
    
    # Convert via SHA1
    $hmacsha1 = new-object System.Security.Cryptography.HMACSHA1;  
    $hmacsha1.Key = [System.Text.Encoding]::ASCII.GetBytes($signature_key);  
    $oauth_signature = [System.Convert]::ToBase64String($hmacsha1.ComputeHash([System.Text.Encoding]::ASCII.GetBytes($signature)));  
    
    # Build OAuth Header
    $oauth_authorization = 'OAuth ';  
    $oauth_authorization += 'oauth_consumer_key="' + [System.Uri]::EscapeDataString($oauth_consumer_key) + '", ';  
    $oauth_authorization += 'oauth_nonce="' + [System.Uri]::EscapeDataString($oauth_nonce) + '", ';  
    $oauth_authorization += 'oauth_signature="' + [System.Uri]::EscapeDataString($oauth_signature) + '", ';  
    $oauth_authorization += 'oauth_signature_method="HMAC-SHA1", '  
    $oauth_authorization += 'oauth_timestamp="' + [System.Uri]::EscapeDataString($oauth_timestamp) + '", '  
    $oauth_authorization += 'oauth_token="' + [System.Uri]::EscapeDataString($oauth_token) + '", ';  
    $oauth_authorization += 'oauth_version="1.0"';  
    
    # Build Body
    $post_body = [System.Text.Encoding]::ASCII.GetBytes("status=" + $status);     
    
    # Set basic information for Invoke-RestMethod
    $headers = @{"Authorization" = $oauth_authorization}
    $contenttype = "application/x-www-form-urlencoded"
    $post_body

    #Post a Tweet
    Invoke-RestMethod -Method Post -Uri "https://api.twitter.com/1.1/statuses/update.json" -Headers $headers -ContentType $contenttype -Body $post_body
}