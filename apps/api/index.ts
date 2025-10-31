import { createSchema } from "@bun-issue/validation";

const data = {
  name: "John Doe",
  email: "john.doe@example.com",
  password: "password",
};

const validatedData = createSchema.parse(data);

console.log(validatedData);
