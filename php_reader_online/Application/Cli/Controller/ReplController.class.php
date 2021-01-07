<?php
namespace Cli\Controller;

class ReplController extends ClibaseController
{
	function index()
	{
		$Boris = new \Behavior\BorisBehavior();
		$Boris ->run();
	}
}