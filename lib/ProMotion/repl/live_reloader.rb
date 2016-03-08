class LiveReloader
  attr_reader :path_query, :opts

  def initialize(path, opts={})
    @path_query = path
    @opts = opts
  end

  def watch(&callback)
    log path_query
    log live_file_paths

    @live_reload_timer = every(opts[:interval] || 0.5) do
      live_files.each do |live_file, modified_date|
        if File.exist?(live_file) && File.mtime(live_file) > modified_date
          new_code = File.read(live_file)
          eval(new_code)
          callback.call *[live_file, new_code, parse_class_names(new_code)].first(callback.arity)
          reload_live_files
        end
      end
    end

    log "Watching #{path_query}."
    self
  end

  def stop
    @live_reload_timer.invalidate if @live_reload_timer
    @live_reload_timer = nil
    log "Stopped."
    self
  end

  def debug?
    @opts[:debug]
  end

  private

  def every(interval, &callback)
    NSTimer.scheduledTimerWithTimeInterval(interval, target: callback, selector: 'call:', userInfo: nil, repeats: true)
  end

  def live_files
    @live_files ||= live_file_paths.inject({}) do |out, live_file_path_file|
      out[live_file_path_file] = File.mtime(live_file_path_file)
      out
    end
  end

  def reload_live_files
    @live_files = nil
    live_files
  end

  def log(s)
    puts s.inspect if debug?
    s
  end

  def project_root_path
    NSBundle.mainBundle.infoDictionary["ProjectRootPath"]
  end

  def live_file_paths
    log Dir.glob("#{project_root_path}/#{path_query}").to_a
  end

  def parse_class_names(code)
    log code.split("\n").map do |code_line|
      matched = code_line.match(/^\s*class\s+(\S+)\s+</)
      matched[1] if matched
    end.to_a.compact.to_a
  end
end
