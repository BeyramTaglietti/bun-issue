import z from "zod";

export const createSchema = z.object({
  name: z.string().min(1),
  email: z.email(),
  password: z.string().min(8),
});
