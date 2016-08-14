<?php
/**
 * Class VarnishClient
 *
 * To be replaced with Guzzle in v4
 * RestService doesn't support PURGE requests natively
 *
 * @author Carey Sizer <careysizer@gmail.com>
 */
class VarnishClient extends Object
{
    /**
     * @param $baseurl
     * @param $urlRegex
     * @return RestfulService_Response
     */
    public function purge($baseurl, $urlRegex)
    {
        $ch        = curl_init();
        $options = array(
            CURLOPT_URL             => $baseurl,
            CURLOPT_RETURNTRANSFER  => 1,
            CURLOPT_USERAGENT       => 'SS Varnish-Purge-Client',
            CURLOPT_CONNECTTIMEOUT  => 2,
            CURLOPT_CUSTOMREQUEST   => 'PURGE',
            CURLOPT_HTTPHEADER      => array('X-Purge-Url-Regex: ' . $urlRegex),
        );
        curl_setopt_array($ch, $options);
        curl_exec($ch);
    }
}
