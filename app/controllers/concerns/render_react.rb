module RenderReact
  extend ActiveSupport::Concern

  included do
    def self.react_actions!(*react_actions)
      layout 'chats/chat', only: react_actions
      around_action :render_react, only: react_actions
    end
  end

  def render_react
    render 'retailers/react/index'
  end
end
