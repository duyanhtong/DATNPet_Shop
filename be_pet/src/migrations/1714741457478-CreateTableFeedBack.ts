import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateTableFeedBack1714741457478 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
    CREATE TABLE "feedback" (
        "id" SERIAL PRIMARY KEY,
        "user_id" BIGINT NOT NULL,
        "product_variant_id" BIGINT NOT NULL,
        "order_id" BIGINT NOT NULL,
        "rating" FLOAT,
        "comment" TEXT,
        "image" TEXT,
        "status" VARCHAR NOT NULL,
        "created_at" TIMESTAMP NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP NOT NULL DEFAULT now(),
        "deleted_at" TIMESTAMP
      );
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
    DROP TABLE "feedback";
    `);
  }
}
