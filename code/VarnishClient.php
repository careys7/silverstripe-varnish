<?php
/**
 * Class PurgeClient
 *
 * A wrapper around RestfulService given it doesn't support PURGE and
 * is likely to be replaced in SS 4
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
        $service = new RestfulService($baseurl, 0);
        $headers = array('X-Purge-Regex' => $urlRegex);
        // Make curl request
        $response = $service->curlRequest(
            $service->getAbsoluteRequestURL($baseurl),
            'PURGE',
            null,
            $headers,
            []
        );
        // We don't set up the request or reponse to use
        // the build in RestfulService caching
        $response->setCachedResponse(false);
        return $response;
    }
}
