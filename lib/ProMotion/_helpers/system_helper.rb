module ProMotion
  module SystemHelper
    module_function

    def ios_version
      UIDevice.currentDevice.systemVersion
    end

    def ios_version_is?(version)
      ios_version == version
    end

    def ios_version_greater?(version)
      ios_version > version
    end

    def ios_version_greater_eq?(version)
      ios_version >= version
    end

    def ios_version_less?(version)
      ios_version < version
    end

    def ios_version_less_eq?(version)
      ios_version <= version
    end
  end
end