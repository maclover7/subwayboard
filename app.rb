require 'sinatra/base'
require 'rest-client'
require 'nokogiri'

module Subwayboard
  class Application < Sinatra::Application
    CODE_TO_NAME = {
      'MTA NYCT_1' => '1 Train',
      'MTA NYCT_2' => '2 Train',
      'MTA NYCT_3' => '3 Train',
      'MTA NYCT_4' => '4 Train',
      'MTA NYCT_5' => '5 Train',
      'MTA NYCT_6' => '6 Train',
      'MTA NYCT_7' => '7 Train',
      ###
      'MTA NYCT_A' => 'A Train',
      'MTA NYCT_B' => 'B Train',
      'MTA NYCT_C' => 'C Train',
      'MTA NYCT_D' => 'D Train',
      'MTA NYCT_E' => 'E Train',
      'MTA NYCT_F' => 'F Train',
      'MTA NYCT_G' => 'G Train',
      'MTA NYCT_J' => 'J Train',
      'MTA NYCT_L' => 'L Train',
      'MTA NYCT_M' => 'M Train',
      'MTA NYCT_N' => 'N Train',
      'MTA NYCT_Q' => 'Q Train',
      'MTA NYCT_R' => 'R Train',
      'MTA NYCT_W' => 'W Train',
      ###
      'MTA NYCT_GS' => '42nd St Shuttle'
    }

    get '/' do
      document = RestClient.get("http://web.mta.info/status/ServiceStatusSubway.xml").body
      document = Nokogiri::XML(document)
      document.remove_namespaces!
      document = document.xpath('//Siri//ServiceDelivery//SituationExchangeDelivery')

      lines_with_incidents = Hash.new do |k, v|
        k[v] = {
          'name' => nil,
          'formatted_id' => nil,
          'incidents' => []
        }
      end

      document.xpath('//Situations//PtSituationElement').each do |incident|
        incident.xpath('Affects//VehicleJourneys//AffectedVehicleJourney//LineRef').map(&:text).each do |line|
          line_name = CODE_TO_NAME[line.strip]

          lines_with_incidents[line_name]['formatted_id'] = line.strip.gsub(' ', '_')

          lines_with_incidents[line_name]['incidents'] << {
            'id' => incident.xpath('SituationNumber').text.strip,
            'formatted_id' => line.strip.gsub(' ', '_') + incident.xpath('SituationNumber').text.strip.gsub(' ', '_'),
            'title' => incident.xpath('Summary').text.strip,
            'description' => incident.xpath('LongDescription').text.gsub('&lt;', '<').gsub('&gt;', '>'),
            'reason' => incident.xpath('ReasonName').text.strip,
            'time' => Time.iso8601(incident.xpath('CreationTime').text).strftime('%I:%M %P'),
            'planned' => incident.xpath('Planned').text
          }
        end
      end

      # Remove duplicated incidents for each line
      lines_with_incidents.keys.each do |line|
        lines_with_incidents[line]['incidents'].uniq! { |incident| incident['id'] }
      end

      # Sort alphabetically
      lines_with_incidents = lines_with_incidents.sort_by { |line, _incidents| line.downcase }

      erb :index, locals: {
        current_time: Time.iso8601(document.xpath('ResponseTimestamp').text),
        lines_with_incidents: lines_with_incidents
      }
    end

    private

    def incident_count(line)
      incident_count = line['incidents'].count
      str = "#{incident_count} incident"

      if incident_count > 1
        str << "s"
      end

      planned_incident_count = line['incidents'].select { |i| i['planned'] == 'true' }.length
      str << " (#{planned_incident_count} planned)"

      str
    end
  end
end
