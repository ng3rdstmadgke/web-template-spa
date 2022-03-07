"""mod_item_table

Revision ID: 7d378f451462
Revises: e5ad5d330265
Create Date: 2022-03-06 18:45:02.328336

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import mysql

# revision identifiers, used by Alembic.
revision = '7d378f451462'
down_revision = 'e5ad5d330265'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('items', sa.Column('name', sa.String(length=255, collation='utf8mb4_bin'), nullable=False))
    op.add_column('items', sa.Column('content', mysql.MEDIUMTEXT(), nullable=True))
    op.add_column('items', sa.Column('is_common', sa.Boolean(), nullable=False))
    op.add_column('items', sa.Column('data_format', sa.Enum('CSV', 'TSV', name='dataformat'), nullable=False))
    op.add_column('items', sa.Column('created', sa.DateTime(), nullable=False))
    op.add_column('items', sa.Column('updated', sa.DateTime(), nullable=False))
    op.drop_index('ix_items_id', table_name='items')
    op.drop_index('ix_items_title', table_name='items')
    op.create_index(op.f('ix_items_name'), 'items', ['name'], unique=False)
    op.drop_column('items', 'description')
    op.drop_column('items', 'title')
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('items', sa.Column('title', mysql.VARCHAR(charset='utf8mb4', collation='utf8mb4_bin', length=255), nullable=True))
    op.add_column('items', sa.Column('description', mysql.MEDIUMTEXT(), nullable=True))
    op.drop_index(op.f('ix_items_name'), table_name='items')
    op.create_index('ix_items_title', 'items', ['title'], unique=False)
    op.create_index('ix_items_id', 'items', ['id'], unique=False)
    op.drop_column('items', 'updated')
    op.drop_column('items', 'created')
    op.drop_column('items', 'data_format')
    op.drop_column('items', 'is_common')
    op.drop_column('items', 'content')
    op.drop_column('items', 'name')
    # ### end Alembic commands ###
