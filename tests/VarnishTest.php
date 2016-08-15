<?php

/**
 * Class Vcl4Test
 *
 * @covers Varnish
 * @author Carey Sizer <careysizer@gmail.com>
 */
class VarnishTest extends SapphireTest
{
    /**
     * @covers Varnish::getVclSyntax()
     */
    public function testGetVclSyntax()
    {
        $varnish = Varnish::create();
        $syntax = $varnish->getVclSyntax();
        // Ensure that the interface is used
        $this->assertInstanceOf(
            VclSyntaxInterface::class,
            $syntax
        );
    }

    /**
     * @covers Varnish::getClient()
     */
    public function testGetClient()
    {
        $varnish = Varnish::create();
        $client = $varnish->getClient();
        // Ensure that the right type is returned
        $this->assertInstanceOf(
            VarnishClient::class,
            $client
        );
    }
}
