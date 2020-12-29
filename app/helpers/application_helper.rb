module ApplicationHelper
  def show_date(date)
    date&.strftime('%k:%M %d-%b-%Y')
  end

  def date_from_parameters
    params[:search][:dob] if params[:search].present?
  end

  def show_date_without_hour(date)
    date&.strftime('%d-%b-%Y')
  end

  def show_svg(path)
    File.open("app/assets/images/#{path}", "rb") do |file|
      raw file.read
    end
  end

  def link_resolver()
    @link_resolver ||= Prismic::LinkResolver.new(nil) {|link|
      # URL for the category type
      if link.type == "category"
        "/category/" + link.uid
      # URL for the product type
      elsif link.type == "product"
        "/product/" + link.id
      # Default case for all other types
      else
        "/"
      end
    }
  end

  def meta_title
    content_for?(:meta_title) ? content_for(:meta_title) : "Mercately"
  end

  def meta_description
    content_for?(:meta_description) ? content_for(:meta_description) : "Mercately"
  end

  def og_type
    content_for?(:og_type) ? content_for(:og_type) : "article"
  end

  def og_title
    content_for?(:og_title) ? content_for(:og_title) : ""
  end

  def og_url
    content_for?(:og_url) ? content_for(:og_url) : "https://" + request.host + request.path
  end

  def og_image
    content_for?(:og_image) ? content_for(:og_image) : ""
  end

  def og_description
    content_for?(:og_description) ? content_for(:og_description) : ""
  end
end
