<?php

namespace OCA\Xmas;

use OCP\AppFramework\App;

class Application extends App {

	public function __construct(array $urlParams = []) {
		parent::__construct('xmas', $urlParams);
		$container = $this->getContainer();

		// Start the snow loader
		$loader = new SnowLoader(
			$container->getServer()->getConfig(),
			$container->getServer()->getRequest(),
			$container->getServer()->getUserSession()
		);

	}

}