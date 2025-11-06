module FlashHelper
  FLASH_STYLES = {
    notice: "green",
    success: "green",
    alert: "red",
    error: "red",
    warning: "yellow",
    info: "blue"
  }.freeze

  def flash_class_for(role)
    color = FLASH_STYLES[role.to_sym] || "gray"
    "bg-#{color}-100 border border-#{color}-400 text-#{color}-700"
  end

  def icon_class_for(role)
    color = FLASH_STYLES[role.to_sym] || "gray"
    "text-#{color}-500"
  end
end
