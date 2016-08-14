<?php
/**
 * Class VarnishSiteTreeExtension
 *
 * @author Carey Sizer <careysizer@gmail.com>
 */
class VarnishSiteTreeExtension extends DataExtension
{
    /**
     * Clear the site tree URL from Varnish after publish
     */
    public function onAfterPublish()
    {
        Varnish::purgeSiteTree($this->owner->ID);
    }
}
