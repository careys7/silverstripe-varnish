<?php
/**
 * Class Varnish
 *
 * Issues PURGE requests via PurgeClient for different SS objects
 *
 * @author Carey Sizer <careysizer@gmail.com>
 */
class Varnish extends Object implements Flushable
{
    /**
     * @var VclSyntaxInterface
     */
    protected static $vclSyntax;

    /**
     * @var VarnishClient
     */
    protected static $varnishClient;

    /**
     * This function is triggered early in the request if the "flush" query
     * parameter has been set. Each class that implements Flushable implements
     * this function which looks after it's own specific flushing functionality.
     *
     * @see FlushRequestFilter
     */
    public static function flush()
    {
        return static::purge(self::getVclSyntax()->getPurgeRegex('/'));
    }

    /**
     * Purge a site tree by IDs
     *
     * @param $siteTreeId
     */
    public static function purgeSiteTree($siteTreeId)
    {
        /* @var $siteTree SiteTree */
        $siteTree =  SiteTree::get()->byID($siteTreeId);
        if ($siteTree !== null && $siteTree->exists()) {
            static::purge(static::getVclSyntax()->getPurgeRegex(
                $siteTree->Link()
            ));
        }
    }

    /**
     * Purge a file by its file ID
     *
     * @param $fileId
     */
    public static function purgeFile($fileId)
    {
        $file = File::get()->byID($fileId);
        if ($file !== null && $file->exists()) {
            static::purge(static::getVclSyntax()->getPurgeRegex(
                $file->getFilename()
            ));
        }
    }

    /**
     * Get Vcl Syntax to be using
     * This can allow support for multiple versions of VCL in future
     *
     * @return VclSyntaxInterface
     */
    public static function getVclSyntax()
    {
        if (!static::$vclSyntax) {
            static::$vclSyntax = Vcl4::create();
        }
        return static::$vclSyntax;
    }

    /**
     * @return VarnishClient
     */
    public static function getClient()
    {
        if (!static::$varnishClient) {
            static::$varnishClient = VarnishClient::create();
        }
        return static::$varnishClient;
    }

    /**
     * @param $regex
     * @return RestfulService_Response
     */
    public static function purge($regex)
    {
        return static::getClient()->purge(Director::absoluteBaseURL(), $regex);
    }
}
