import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateTableOrderHistory1713081504504
  implements MigrationInterface
{
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
    CREATE TABLE "order_history" (
        "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
        "order_id" BIGINT NOT NULL,
        "product_variant_id" BIGINT NOT NULL,
        "product_name" VARCHAR NOT NULL,
        "product_variant_name" VARCHAR NOT NULL,
        "image" TEXT NOT NULL,
        "quantity" INT NOT NULL,
        "price_at_purchase" FLOAT NOT NULL,
        "weight" FLOAT NOT NULL,
        "promotion_at_purchase" FLOAT NOT NULL,
        "created_at" TIMESTAMP NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP NOT NULL DEFAULT now(), 
        "deleted_at" TIMESTAMP
    );
    
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
        DROP TABLE "order_history";`);
  }
}
