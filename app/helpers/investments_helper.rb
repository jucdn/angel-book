module InvestmentsHelper
  VEHICLE_LABELS = {
    "direct"  => "Direct",
    "pea_pme" => "PEA-PME",
    "holding" => "Holding"
  }.freeze

  def vehicle_label(vehicle)
    VEHICLE_LABELS.fetch(vehicle.to_s, vehicle.to_s.humanize)
  end
end
