task default: :test

desc 'test'
task :test do
  p 'do rake test'
end

directory 'html/images'

def compile(target, sources, *flags)
  sh 'gcc', '-Wall', '-Werror', '-03', '-o', target, *(sources + flags)
end
o_files = FileList['*.c'].exclude('main.c').sub(/c$/, 'o')

file 'cool_app' => o_files do |t|
  compile(t.name, t.sources)
end

rule '.o' => '.c' do |t|
  compile(t.name, [t.source], '-c')
end
