# resource "time_sleep" "instance_group_propagation" {
#   create_duration = "60s"

#   triggers = {
#     instance_group  = google_compute_instance_group_manager.igm.instance_group
#   }
# }

# resource "time_sleep" "instances_propagation" {
#   create_duration = "60s"

#   triggers = {
#     instances  = time_sleep.instance_group_propagation.instance_group
#   }
# }