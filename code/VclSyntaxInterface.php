<?php
/**
 * Interface VclSyntaxInterface
 *
 * @author Carey Sizer <careysizer@gmail.com>
 */
interface VclSyntaxInterface
{
    /**
     * @param $url
     * @return mixed
     */
    public function getPurgeRegex($url);
}
