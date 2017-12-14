<?php

namespace OCA\Xmas;

use OCP\IConfig;
use OCP\IRequest;
use OCP\IUserSession;
use OCP\Util;

class SnowLoader {

	/**
	 * @var IConfig
	 */
	protected $config;
	/**
	 * @var IRequest
	 */
	protected $request;
	/**
	 * @var IUserSession
	 */
	protected $userSession;

	public function __construct(
		IConfig $config,
		IRequest $request,
		IUserSession $userSession) {
		$this->config = $config;
		$this->request = $request;
		$this->userSession = $userSession;

		// Get the config, default to all snow!
		$showOnLogin = $this->config->getAppValue(
			'xmas',
			'showOnLogin',
			'true') === 'true';
		$showOnPublicShare = $this->config->getAppValue(
			'xmas',
			'showOnPublicShare',
			'true') === 'true';
		$showOnFiles = $this->config->getAppValue(
			'xmas',
			'showOnFiles',
			'true') === 'true';

		// If requested, and condition matches, go snow!
		if(
			($showOnLogin && $this->isLogin())
			|| ($showOnPublicShare && $this->isPublicShare()
			|| ($showOnFiles && $this->isFilesApp()))) {
			$this->goSnow();
		}


	}

	/**
	 * Make it snow!
	 */
	protected function goSnow() {
		Util::addScript('xmas', 'vendor');
		Util::addScript('xmas', 'snowflakes');
		Util::addStyle('xmas', 'style');
	}

	/**
	 * Detect if we are on the login page
	 * @return bool
	 */
	private function isLogin() {
		return $this->userSession->isLoggedIn() !== true
			&& strpos($this->request->getRequestUri(), '/login') !== false;
	}

	/**
	 * Detect if we are on the login page
	 * @return bool
	 */
	private function isPublicShare() {
		return strpos($this->request->getRequestUri(), '/s/') !== false;
	}

	/**
	 * Detect if we are on the login page
	 * @return bool
	 */
	private function isFilesApp() {
		return $this->userSession->isLoggedIn()
			&& strpos($this->request->getRequestUri(), '/apps/files') !== false;
	}

}