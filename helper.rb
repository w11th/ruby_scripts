require 'benchmark'

def print_memroy_usage
  memory_before = `ps -o rss= -p #{Process.pid}`.to_i
  yield
  memory_after = `ps -o rss= -p #{Process.pid}`.to_i
  puts "Memroy: #{((memory_after - memory_before) / 1024).round(2)} MB"
end

def print_time_spent
  time = Benchmark.realtime do
    yield
  end
  puts "Time: #{time.round(2)} s"
end

def perform
  print_memroy_usage do
    print_time_spent do
      yield
    end
  end
end
