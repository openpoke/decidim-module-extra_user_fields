import { Application } from "@hotwired/stimulus"
import FieldStateController from "src/decidim/extra_user_fields/admin/field_state_controller"
import CollectionFieldController from "src/decidim/extra_user_fields/admin/collection_field_controller"

const application = Application.start()
application.register("field-state", FieldStateController)
application.register("collection-fields", CollectionFieldController)
