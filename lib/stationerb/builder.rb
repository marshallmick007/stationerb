require 'erb'

module Stationerb
  class Builder
    PARTS = %w{head _hero main_body _rows end_main_body _footer end}

    #hero -> https://coolors.co/d62839-ba324f-175676-4ba3c3-cce6f4
    #footer -> https://coolors.co/5a5353-a07178-e6ccbe-776274-c8cc92
    #scale -> https://coolors.co/ffbf00-3e92cc-32936f-d8315b-e83f6f
    DEFAULT_OPTS = {
      :body_bg => "#f2f7f2",
      :body_fg => "#3d2b3d",
      :hero_bg => "#4ba3c3",
      :hero_fg => "#cce6f4",
      :footer_bg => "#5a5353",
      :footer_fg => "#e6ccbe",
      :views => "views",
      :font => "'Helvetica Neue',Helvetica,Arial,sans-serif",
      :scale_red => '#d8315b',
      :scale_blue => '#3e92cc',
      :scale_green => '#32936f'
    }

    #alt_footer_fg = "#c8cc92" -> https://coolors.co/5a5353-a07178-e6ccbe-776274-c8cc92

    def initialize(opts = {})
      opts[:font] = Stationerb.configuration.font if opts[:font].nil?
      @opts = DEFAULT_OPTS.merge(opts)
      @data = {}
      @hero = nil
      @rows = []
      @footer = nil
    end

    def add_hero(title, body)
      @data = {
        :hero_title => title,
        :hero_body => body
      }
      @hero = render("hero")
    end

    def add_row(header, content)
      @data = {
        :row_header => header,
        :row_content => content
      }
      @rows << render("standard_row")
    end

    def add_prerendered_row(rendered_row)
      @rows << rendered_row
    end

    def add_comparison_row(title, current, previous)
      @data = {
        :row_comparison_label => title,
        :row_current_value => current,
        :row_previous_value => previous,
        :row_comparison_sign => compute_diff_sign(current, previous),
        :row_compare_percent => compute_diff_percent(current, previous)
      }
      @rows << render("comparison_row")
    end

    def compute_diff_percent(current, previous)
      diff_percent = (current.to_f / previous.to_f * 100.0) unless previous == 0.0
      diff_percent ||= 0
      # growth for large changes can be larger than 100%
      diff_percent > 100.0 ? scale_growth(diff_percent) : diff_percent.to_i
    end

    def scale_growth(value)
      xtimes = value / 100.0
      scale = 100.0 - (100.0 / xtimes)
      scale > 100.0 ? 100 : scale
    end

    def compute_diff_sign(current, previous)
      (current - previous) >= 0 ? :positive : :negative
    end

    def add_footer(title, url, rows = [])
      @data = {
        :footer_title => title,
        :footer_url => url,
        :footer_rows => rows
      }
      @footer = render("footer")
    end

    def generate(subject)
      @data = {
        :subject => subject
      }

      email = ""
      PARTS.each do |part|
        if part.start_with? '_'
          email += get_part(part)
        else
          email += render(part)
        end
      end
      email
    end

    def get_part(part)
      if part == "_hero" && @hero
        return @hero
      elsif part == "_footer" && @footer
        return @footer
      elsif part == "_rows" && @rows.length > 0
        return @rows.join(" ")
      end
      return ""
    end

    def render(template)
      renderer = ERB.new(File.read(get_template(template)))
      b = binding
      b.local_variable_set(:opts, @opts)
      b.local_variable_set(:data, @data)
      renderer.result(b)
    end

    def get_template(file)
      if has_user_view?(file)
        return get_user_view_path(file)
      end
      File.join(Stationerb.configuration.built_in_views, "#{file}.erb")
    end

    def has_user_view?(file)
      if Stationerb.configuration.views
        return File.exists? get_user_view_path(file)
      end
      false
    end

    def get_user_view_path(file)
      File.join(Stationerb.configuration.views, "#{file}.erb")
    end
  end
end
