# targets class
class Targets
  def initialize(client, project, tools, pool)
    @machine = client.machine
    @client = client
    @project = project
    @tools = tools
    @pool = pool
    @logger = project.logger
  end

  def add_target_to_project
    tag = @project.tag
    machine = @machine['name']
    target = search_target
    key = target['key']
    @tools.create_project_target(key, tag, machine)
    target
  end

  def search_target
    @logger.info("Searching for target #{target_name}")
    list_targets.each do |target|
      return target if target['name'].include?(target_name)
    end
    @logger.fatal('Target not found')
    raise 'target not found'
  rescue StandardError
    @client.reconfigure_machine
    retry
  end

  def target_name
    return @machine['name'] if @project.device['device']['type'] == 'system'

    @project.device['name']
  end

  def list_targets
    name = @machine['name']
    @logger.info("listing targets of #{name}")
    @tools.list_machine_targets(name, @pool)
  end
end
