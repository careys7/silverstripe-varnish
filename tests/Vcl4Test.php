<?php

/**
 * Class Vcl4Test
 *
 * @covers Vcl4
 * @author Carey Sizer <careysizer@gmail.com>
 */
class Vcl4Test extends SapphireTest
{
    /**
     * @covers Vcl4::getPurgeRegex()
     */
    public function testGetPurgeRegex()
    {
        $vcl4 = Vcl4::create();
        $this->assertEquals(
            '^/about\-us(\/|)$',
            $vcl4->getPurgeRegex('about-us')
        );
    }
}
