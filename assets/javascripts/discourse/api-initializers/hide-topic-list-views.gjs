import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  // Modern Discourse topic lists expose desktop columns through a DAG API.
  // Removing the "views" column here is cleaner than taking over the whole row template.
  api.registerValueTransformer("topic-list-columns", ({ value: columns }) => {
    if (columns?.delete) {
      columns.delete("views");
    }
  });
});
