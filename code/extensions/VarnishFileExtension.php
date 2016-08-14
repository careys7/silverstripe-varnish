<?php
/**
 * Class VarnishFileExtension
 *
 * @author Carey Sizer <careysizer@gmail.com>
 */
class VarnishFileExtension extends DataExtension
{
    /**
     * Purge file from Varnish after write
     */
    public function onAfterWrite()
    {
        Varnish::purgeFile($this->owner->ID);
    }
}
