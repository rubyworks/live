module Kernel
  alias :custom_require :require

  def require(path)
    p path
    custom_require(path)
  end
end

