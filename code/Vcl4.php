<?php
/**
 * Class Vcl4
 *
 * Implements VCL syntax for Varnish V4
 *
 * @author Carey Sizer <careysizer@gmail.com>
 */
class Vcl4 extends Object implements VclSyntaxInterface
{
    /**
     * @param $url
     * @return string
     */
    public function getPurgeRegex($url)
    {
        return sprintf('obj.http.x-url ~ %s', $url);
    }
}
