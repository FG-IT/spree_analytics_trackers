if Gem.loaded_specs['spree_core'].version >= Gem::Version.create('3.5.0')
  Deface::Override.new(
    virtual_path: 'spree/admin/shared/sub_menu/_configuration',
    name: 'add_analytics_to_admin_sidebar',
    insert_bottom: '[data-hook="admin_configurations_sidebar_menu"]',
    partial: 'spree/admin/shared/analytics_sidebar_menu'
  )

  Deface::Override.new(
    virtual_path: 'spree/admin/shared/_main_menu',
    name: 'Matomo Analytics',
    insert_bottom: 'nav',
    text: <<-HTML
      <ul class="nav nav-sidebar border-bottom" id="sidebarAnalytics">
        <%= tab Spree.t(:analytics), icon: "report.svg", route: :admin_matomo_analytics %>
      </ul>
    HTML
  )
end
