<?php
/**
 * SocialEngine
 *
 * @category   Application_Core
 * @package    Core
 * @copyright  Copyright 2006-2010 Webligo Developments
 * @license    http://www.socialengine.net/license/
 * @version    $Id: default.tpl 9089 2011-07-21 23:12:11Z john $
 * @author     John
 */
?>

<?php echo $this->doctype()->__toString() ?>
<?php $locale = $this->locale()->getLocale()->__toString();
$orientation = ($this->layout()->orientation == 'right-to-left' ? 'rtl' : 'ltr'); ?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="<?php echo $locale ?>" lang="<?php echo $locale ?>" dir="<?php echo $orientation ?>">
<head>
    <base
        href="<?php echo rtrim((constant('_ENGINE_SSL') ? 'https://' : 'http://') . $_SERVER['HTTP_HOST'] . $this->baseUrl(), '/') . '/' ?>"/>

  <?php echo $this->hooks('onRenderLayoutDefault', $this) ?>

    <?php
    $counter = (int)$this->layout()->counter;

    $request = Zend_Controller_Front::getInstance()->getRequest();

    $title = $this->translate('TIMELINE_Profile_title %s', $this->subject()->getTitle());

    $this->headTitle($title, Zend_View_Helper_Placeholder_Container_Abstract::SET);

    $this->headMeta()
        ->appendHttpEquiv('Content-Type', 'text/html; charset=UTF-8')
        ->appendHttpEquiv('Content-Language', 'en-US');

// Make description and keywords
    $description = '';
    $keywords = '';

    $description .= ' ' . $this->layout()->siteinfo['description'];
    $keywords = $this->layout()->siteinfo['keywords'];

    if ($this->subject() && $this->subject()->getIdentity()) {
        // $this->headTitle($this->subject()->title);
        // $description .= ' ' .$this->subject()->getDescription();
        if (!empty($keywords)) $keywords .= ',';
        $keywords .= $this->subject()->getKeywords(',');
    }

    $this->headMeta()->appendName('description', trim($description));
    $this->headMeta()->appendName('keywords', trim($keywords));
// Get body identity
    if (isset($this->layout()->siteinfo['identity'])) {
        $identity = $this->layout()->siteinfo['identity'];
    } else {
        $identity = $request->getModuleName() . '-' .
            $request->getControllerName() . '-' .
            $request->getActionName();
    }
    ?>
    <?php echo $this->headTitle()->toString() . "\n" ?>
    <?php echo $this->headMeta()->toString() . "\n" ?>

    <?php // LINK/STYLES
    $this->headLink(array(
            'rel' => 'favicon',
            'href' => (isset($this->layout()->favicon)
                ? $this->baseUrl() . $this->layout()->favicon
                : '/favicon.ico'),
            'type' => 'image/x-icon'),
        'PREPEND');
    $themes = array();
    if (!empty($this->layout()->themes)) {
        $themes = $this->layout()->themes;
    } else {
        $themes = array('default');
    }
    foreach ($themes as $theme) {
        $this->headLink()
            ->prependStylesheet($this->baseUrl() . '/application/css.php?request=application/themes/' . $theme . '/theme.css');
        if ($orientation == 'rtl') {
            // @todo add include for rtl
        }
    }

// Process
    foreach ($this->headLink()->getContainer() as $dat) {
        if (!empty($dat->href)) {
            if (false === strpos($dat->href, '?')) {
                $dat->href .= '?c=' . $counter;
            } else {
                $dat->href .= '&c=' . $counter;
            }
        }
    }
    ?>
    <?php echo $this->headLink()->toString() . "\n" ?>
    <?php echo $this->headStyle()->toString() . "\n" ?>

    <?php
    // TODO Optimizer Michael's modification
    // Small fix for minify
    $this->headTranslate(array(
      'WALL_LOADING',
      'HETIPS_LOADING'
    ));
    // end TODO Optimizer Michael's modification
    ?>

    <?php // TRANSLATE ?>
    <?php $this->headScript()->prependScript($this->headTranslate()->toString()) ?>

    <?php // SCRIPTS ?>
    <script type="text/javascript">
        <?php echo $this->headScript()->captureStart(Zend_View_Helper_Placeholder_Container_Abstract::PREPEND) ?>

        en4.orientation = '<?php echo $orientation ?>';

        en4.core.language.setLocale('<?php echo $this->locale()->getLocale()->__toString() ?>');

        Date.setServerOffset('<?php echo date('D, j M Y G:i:s O', time()) ?>');

        en4.orientation = '<?php echo $orientation ?>';
        en4.core.environment = '<?php echo APPLICATION_ENV ?>';
        en4.core.language.setLocale('<?php echo $this->locale()->getLocale()->__toString() ?>');
        en4.core.loader = new Element('img', {src:'application/modules/Core/externals/images/loading.gif'});

        en4.core.setBaseUrl('<?php echo $this->url(array(), 'default', true) ?>');
        en4.core.loader = new Element('img', {src:'application/modules/Core/externals/images/loading.gif'});

        <?php if ($this->subject()): ?>
        en4.core.staticBaseUrl = '<?php echo $this->escape($this->layout()->staticBaseUrl) ?>';
        en4.core.subject = {
            type:'<?php echo $this->subject()->getType(); ?>',
            id: <?php echo (int)$this->subject()->getIdentity(); ?>,
            guid:'<?php echo $this->subject()->getGuid(); ?>'
        };
            <?php endif; ?>
        <?php if ($this->viewer()->getIdentity()): ?>
        en4.user.viewer = {
            type:'<?php echo $this->viewer()->getType(); ?>',
            id: <?php echo $this->viewer()->getIdentity(); ?>,
            guid:'<?php echo $this->viewer()->getGuid(); ?>'
        };
            <?php endif; ?>
        if ( <?php echo (Zend_Controller_Front::getInstance()->getRequest()->getParam('ajax', false) ? 'true' : 'false') ?> ) {
            en4.core.dloader.attach();
        }
        <?php echo $this->headScript()->captureEnd(Zend_View_Helper_Placeholder_Container_Abstract::PREPEND) ?>
    </script>

  <?php
  // TODO Optimizer Michael's modification
  ?>
  <?php
  $staticBaseUrl = $this->layout()->staticBaseUrl;
  $this->headScript()
      ->prependFile($staticBaseUrl . 'application/modules/Optimizer/externals/scripts/head.min.js')
      ->prependFile($staticBaseUrl . 'application/modules/Optimizer/externals/scripts/core.js')
      ->prependFile($staticBaseUrl . 'externals/smoothbox/smoothbox4.js')
      ->prependFile($staticBaseUrl . 'application/modules/User/externals/scripts/core.js')
      ->prependFile($staticBaseUrl . 'application/modules/Core/externals/scripts/core.js')
      ->prependFile($staticBaseUrl . 'externals/chootools/chootools.js');

  $whitelist = array();
  if (Engine_Api::_()->getDbTable('modules', 'core')->isModuleEnabled('optimizer') &&
      Engine_Api::_()->getDbTable('settings', 'core')->getSetting('optimizer.minify.enabled', 1) &&
      empty($_GET['no_minify'])
  ){
    $whitelist = Engine_Api::_()->optimizer()->getWhitelist();
  }


  $min_files = array();
  $container = $this->headScript()->getContainer();

  foreach ($container as $key => $dat){

    // to minify
    if (!empty($dat->attributes['src'])){

      $src = $dat->attributes['src'];
      $src = str_replace($this->staticBaseUrl, '', $src);
      $src = str_replace($this->baseUrl(), '', $src);
      $src = '/'. trim($src, '/');

      $short_key = array_search($src, $whitelist);
      if ($short_key){
        $min_files[] = $short_key;
        unset($container[$key]);
        continue;
      }
    } else {
      if (!empty($dat->attributes['src'])){
        if (false === strpos($dat->attributes['src'], '?')){
          $dat->attributes['src'] .= '?c=' . $counter;
        } else {
          $dat->attributes['src'] .= '&c=' . $counter;
        }
      }
    }
  }
  ?>
  <?php
  // Support old versions of Social Engine
  $core_version = Engine_Api::_()->getDbTable('modules', 'core')->getModule('core')->version;
  ?>
  <?php if (version_compare($core_version, '4.1.7') < 0):?>
    <script type="text/javascript" src="<?php echo $staticBaseUrl . 'externals/mootools/mootools-1.2.4-core-' . (APPLICATION_ENV == 'development' ? 'nc' : 'yc') . '.js'?>"></script>
    <script type="text/javascript" src="<?php echo $staticBaseUrl . 'externals/mootools/mootools-1.2.4.4-more-' . (APPLICATION_ENV == 'development' ? 'nc' : 'yc') . '.js';?>"></script>
  <?php elseif(version_compare($core_version, '4.2.2') < 0):?>
    <script type="text/javascript" src="<?php echo $staticBaseUrl . 'externals/mootools/mootools-1.2.5-core-' . (APPLICATION_ENV == 'development' ? 'nc' : 'yc') . '.js';?>"></script>
    <script type="text/javascript" src="<?php echo $staticBaseUrl . 'externals/mootools/mootools-1.2.5.1-more-' . (APPLICATION_ENV == 'development' ? 'nc' : 'yc') . '.js'?>"></script>
  <?php else:?>
    <script type="text/javascript" src="<?php echo $staticBaseUrl . 'externals/mootools/mootools-core-1.4.5-full-compat-' . (APPLICATION_ENV == 'development' ? 'nc' : 'yc') . '.js'?>"></script>
    <script type="text/javascript" src="<?php echo $staticBaseUrl . 'externals/mootools/mootools-more-1.4.0.1-full-compat-' . (APPLICATION_ENV == 'development' ? 'nc' : 'yc') . '.js';?>"></script>
  <?php endif;?>

  <?php
  if (!empty($min_files)){
    $minified_url = $this->layout()->staticBaseUrl . 'application/modules/Optimizer/extensions/min/index.php?f=' . implode(',', $min_files);
    echo '<script src="' . $minified_url . '"></script>';
  }
  ?>

  <?php echo $this->headScript()->toString()."\n" ?>

  <?php
  // end TODO Optimizer Michael's modification
  ?>
  <?php $headIncludes = $this->layout()->headIncludes;?>
  <?php echo $headIncludes ?>

</head>
<body
    id="global_page_<?php echo $request->getModuleName() . '-' . $request->getControllerName() . '-' . $request->getActionName() ?>">

<?php
// TODO Optimizer Michael's modification
?>
<?php if (Engine_Api::_()->getDbTable('modules', 'core')->isModuleEnabled('optimizer', 'core')):?>
  <script type="text/javascript">
    AjaxWidget.url = '<?php echo $this->baseUrl();?>/optimizer/index/widget';
    AjaxWidget.ajax_widgets = <?php echo $this->jsonInline(Engine_Api::_()->optimizer()->getAjaxWidgets());?>;
    AjaxWidget.run();
  </script>
<?php endif;?>
<?php
// end TODO Optimizer Michael's modification
?>

<div class="page-search-results hidden" id="page-search-results"></div>
<div id="global_header">
    <?php echo $this->content('header'); ?>
</div>
<div id='global_wrapper'>
    <div id='global_content'>
        <?php echo $this->layout()->content ?>
    </div>
</div>
<div id="global_footer">
    <?php echo $this->content('footer'); ?>
</div>
</body>
</html>