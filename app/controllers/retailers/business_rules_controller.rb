class Retailers::BusinessRulesController < RetailersController
  layout 'chats/chat', only: :index

  def index
    category = RuleCategory.first
    @rules = BusinessRule.where(rule_category_id: category.id).order(:id)
  end

  def manage_retailer_rule
    retailer_rule = current_retailer.retailer_business_rules.find_by(business_rule_id: params[:rule_id])

    if retailer_rule
      retailer_rule.destroy!
      render status: :ok, json: { message: 'Regla eliminada con éxito' }
    else
      current_retailer.retailer_business_rules.create!(business_rule_id: params[:rule_id])
      render status: :ok, json: { message: 'Regla agregada con éxito' }
    end
  rescue StandardError => e
    render status: :unprocessable_entity, json: { message: e.message }
  end
end
