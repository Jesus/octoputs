require 'octoputs/logger'

class ThreadPool
  def initialize(size)
    @id = 0
    @tasks = []

    @mutex = Mutex.new
    @task_arrival = ConditionVariable.new

    @threads = size.times.map { spawn }

    @shutting_down = false
  end

  def enqueue(&task)
    @tasks << task
    @task_arrival.signal
  end

  def spawn
    @id += 1
    Thread.new(@id) do |id|
      until @shutting_down
        # Try to consume a task
        task = @tasks.shift
        task.call unless task.nil?

        @mutex.synchronize do
          if @tasks.empty?
            # Block until a task arrives (or #shut_down forces a loop cycle)
            @task_arrival.wait @mutex
          end
        end
      end
    end
  end

  def shut_down
    @shutting_down = true
    @task_arrival.broadcast

    @threads.each(&:join)
  end
end
