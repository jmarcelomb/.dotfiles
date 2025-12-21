# Work-related SSH shortcuts and configurations
# Requires: conf.d/work_config.fish with environment variables

function p1
    ssh -qt $KBM_SVC_USERNAME@$KBM_PROD_SERVER_01 "$argv"
end

function d1
    ssh -qt $KBM_SVC_USERNAME@$KBM_DEV_SERVER_01 "$argv"
end
