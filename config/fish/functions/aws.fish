function aws --wraps='docker run --rm -it public.ecr.aws/aws-cli/aws-cli' --description 'alias aws=docker run --rm -it public.ecr.aws/aws-cli/aws-cli'
  docker run --rm -it public.ecr.aws/aws-cli/aws-cli $argv
        
end
