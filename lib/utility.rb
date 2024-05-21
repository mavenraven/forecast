
module Utility
  def self.highest_confidence results
    highest_confidence = nil
    results.each do |result|
      if highest_confidence.nil?
        highest_confidence = result
      else
        if not result.instance_values["data"].nil? and not result.instance_values["data"]["confidence"].nil?
          if result.instance_values["data"]["confidence"] > highest_confidence.instance_values["data"]["confidence"]
            highest_confidence = result
          end
        end
      end
    end
    highest_confidence
  end
end