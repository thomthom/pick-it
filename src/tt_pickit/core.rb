#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'


#-------------------------------------------------------------------------------

module TT::Plugins::PickIt


  ### MENU & TOOLBARS ### --------------------------------------------------

  unless file_loaded?( __FILE__ )
    parent_menu = ($tt_menu) ? $tt_menu : UI.menu('Tools')
    parent_menu.add_item('Pickit')  { self.pickit }
  end


  ### MAIN SCRIPT ### ------------------------------------------------------

  def self.pickit
    Sketchup.active_model.tools.push_tool(PickIt.new)
  end


  class PickIt

    def activate
      @entities = []
    end

    def onLButtonUp(flags, x, y, view)
      ph = view.pick_helper
      ph.do_pick(x, y)
      Sketchup.active_model.selection.clear
      Sketchup.active_model.selection.add(ph.best_picked) unless ph.best_picked.nil?
    end

    def onMouseMove(flags, x, y, view)
      ph = view.pick_helper
      ph.do_pick(x, y)
      @entities = ph.all_picked
    end

    def getMenu(menu)
      @menus = {}
      @entities.each { |e|
        @menus[e] = if e.class == Sketchup::Group
          (e.name.empty?) ? e.to_s : "#{e.name} (#{e.to_s})"
        elsif e.class == Sketchup::ComponentInstance
          if e.name.empty?
            "#{e.definition.name} (#{e.to_s})"
          else
            "#{e.definition.name} > #{e.name} (#{e.to_s})"
          end
        else
          e.to_s
        end
      }
      @menus.sort{|a,b| a[1]<=>b[1]}.each { |e, menu_text|
        menu.add_item(menu_text) {
          Sketchup.active_model.selection.clear
          Sketchup.active_model.selection.add(e)
        }
      }
    end

  end


end # module

#-------------------------------------------------------------------------------

file_loaded( __FILE__ )

#-------------------------------------------------------------------------------
