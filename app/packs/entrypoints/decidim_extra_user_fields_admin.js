import { Application } from "@hotwired/stimulus"
import FieldStateController from "src/decidim/extra_user_fields/admin/field_state_controller"

const application = Application.start()
application.register("field-state", FieldStateController)
