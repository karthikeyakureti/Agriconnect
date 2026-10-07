from fastapi import APIRouter, Depends
from fastapi.responses import HTMLResponse
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.user import User
from app.models.product import Product
from app.models.order import Order
from app.models.message import Message

router = APIRouter(tags=["Admin Database Dashboard"])

@router.get("/admin", response_class=HTMLResponse)
def admin_database_dashboard(db: Session = Depends(get_db)):
    users = db.query(User).order_by(User.id.asc()).all()
    products = db.query(Product).order_by(Product.id.desc()).all()
    orders = db.query(Order).order_by(Order.id.desc()).all()
    messages = db.query(Message).order_by(Message.id.desc()).all()

    users_rows = "".join([
        f"""
        <tr>
            <td class="id-badge">#{u.id}</td>
            <td><strong>{u.name}</strong></td>
            <td><code>{u.email}</code></td>
            <td><span class="role-badge role-{u.role.value.lower()}">{u.role.value}</span></td>
            <td>{u.phone or '<span class="text-muted">None</span>'}</td>
            <td>{u.location or '<span class="text-muted">None</span>'}</td>
            <td class="text-muted">{u.created_at.strftime('%Y-%m-%d %H:%M') if u.created_at else '-'}</td>
        </tr>
        """ for u in users
    ])

    products_rows = "".join([
        f"""
        <tr>
            <td class="id-badge">#{p.id}</td>
            <td><img src="{p.image_url or ''}" class="thumb" onerror="this.src='https://via.placeholder.com/40'"/> <strong>{p.name}</strong></td>
            <td><span class="cat-badge">{p.category}</span></td>
            <td><strong>{p.quantity:,.0f} kg</strong></td>
            <td><strong class="price">₹{p.price_per_kg:,.0f}/kg</strong></td>
            <td>{p.farmer.name if p.farmer else f'Farmer #{p.farmer_id}'}</td>
            <td>{p.location or '-'}</td>
            <td><span class="status-badge status-{p.status.value.lower()}">{p.status.value}</span></td>
        </tr>
        """ for p in products
    ])

    orders_rows = "".join([
        f"""
        <tr>
            <td class="id-badge"><strong>#AGI{o.id:04d}</strong></td>
            <td>{o.product.name if o.product else f'Product #{o.product_id}'}</td>
            <td>{o.quantity:,.0f} kg</td>
            <td><strong class="price">₹{o.total_price:,.0f}</strong></td>
            <td>{o.buyer.name if o.buyer else f'Buyer #{o.buyer_id}'}</td>
            <td>{o.farmer.name if o.farmer else f'Farmer #{o.farmer_id}'}</td>
            <td><span class="status-badge status-{o.status.value.lower()}">{o.status.value}</span></td>
            <td class="text-muted">{o.created_at.strftime('%Y-%m-%d %H:%M') if o.created_at else '-'}</td>
        </tr>
        """ for o in orders
    ])

    messages_rows = "".join([
        f"""
        <tr>
            <td class="id-badge">#{m.id}</td>
            <td><strong>{m.sender.name if m.sender else f'User #{m.sender_id}'}</strong></td>
            <td><strong>{m.receiver.name if m.receiver else f'User #{m.receiver_id}'}</strong></td>
            <td class="msg-content">{m.message}</td>
            <td class="text-muted">{m.created_at.strftime('%Y-%m-%d %H:%M') if m.created_at else '-'}</td>
            <td>{'<span class="read-yes">Read</span>' if m.read_status else '<span class="read-no">Unread</span>'}</td>
        </tr>
        """ for m in messages
    ])

    html_content = f"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>AgriConnect Database Console</title>
        <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
        <style>
            :root {{
                --primary: #1B5E20;
                --primary-light: #2E7D32;
                --bg: #F8FAF8;
                --surface: #FFFFFF;
                --border: #E2E8F0;
                --text-main: #0F172A;
                --text-muted: #64748B;
            }}
            * {{ box-sizing: border-box; margin: 0; padding: 0; }}
            body {{
                font-family: 'Plus Jakarta Sans', sans-serif;
                background-color: var(--bg);
                color: var(--text-main);
                padding: 24px;
            }}
            .header {{
                display: flex;
                justify-content: space-between;
                align-items: center;
                background: white;
                padding: 20px 28px;
                border-radius: 16px;
                border: 1px solid var(--border);
                box-shadow: 0 2px 8px rgba(0,0,0,0.03);
                margin-bottom: 24px;
            }}
            .brand {{
                display: flex;
                align-items: center;
                gap: 12px;
            }}
            .logo-icon {{
                background: #E8F5E9;
                color: var(--primary);
                width: 44px;
                height: 44px;
                border-radius: 12px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 24px;
            }}
            .brand h1 {{
                font-size: 22px;
                font-weight: 800;
                color: var(--primary);
            }}
            .brand p {{
                font-size: 13px;
                color: var(--text-muted);
            }}
            .metrics-grid {{
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 16px;
                margin-bottom: 24px;
            }}
            .metric-card {{
                background: white;
                padding: 18px 20px;
                border-radius: 14px;
                border: 1px solid var(--border);
            }}
            .metric-title {{
                font-size: 12px;
                font-weight: 600;
                color: var(--text-muted);
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }}
            .metric-value {{
                font-size: 28px;
                font-weight: 800;
                color: var(--text-main);
                margin-top: 4px;
            }}
            .nav-tabs {{
                display: flex;
                gap: 8px;
                margin-bottom: 18px;
                border-bottom: 1px solid var(--border);
                padding-bottom: 8px;
            }}
            .tab-btn {{
                background: white;
                border: 1px solid var(--border);
                padding: 10px 18px;
                border-radius: 10px;
                font-family: inherit;
                font-size: 14px;
                font-weight: 600;
                cursor: pointer;
                display: flex;
                align-items: center;
                gap: 8px;
                transition: all 0.15s ease;
            }}
            .tab-btn.active {{
                background: var(--primary);
                color: white;
                border-color: var(--primary);
            }}
            .tab-content {{
                display: none;
                background: white;
                border-radius: 16px;
                border: 1px solid var(--border);
                overflow: hidden;
                box-shadow: 0 2px 8px rgba(0,0,0,0.02);
            }}
            .tab-content.active {{
                display: block;
            }}
            table {{
                width: 100%;
                border-collapse: collapse;
                text-align: left;
                font-size: 13.5px;
            }}
            th {{
                background: #F8FAFC;
                color: var(--text-muted);
                font-weight: 700;
                padding: 14px 18px;
                border-bottom: 1px solid var(--border);
                font-size: 12px;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }}
            td {{
                padding: 14px 18px;
                border-bottom: 1px solid #F1F5F9;
                vertical-align: middle;
            }}
            tr:hover td {{
                background-color: #F8FAF8;
            }}
            .id-badge {{
                font-family: 'JetBrains Mono', monospace;
                font-weight: 600;
                color: var(--text-muted);
            }}
            .role-badge {{
                padding: 4px 10px;
                border-radius: 20px;
                font-size: 11px;
                font-weight: 700;
                letter-spacing: 0.5px;
            }}
            .role-farmer {{
                background: #E8F5E9;
                color: #2E7D32;
            }}
            .role-buyer {{
                background: #E0F2FE;
                color: #0369A1;
            }}
            .status-badge {{
                padding: 4px 10px;
                border-radius: 20px;
                font-size: 11px;
                font-weight: 700;
            }}
            .status-active, .status-confirmed, .status-delivered {{
                background: #DCFCE7;
                color: #15803D;
            }}
            .status-pending {{
                background: #FEF3C7;
                color: #B45309;
            }}
            .status-cancelled, .status-sold_out {{
                background: #FEE2E2;
                color: #B91C1C;
            }}
            .cat-badge {{
                background: #F1F5F9;
                padding: 4px 8px;
                border-radius: 6px;
                font-weight: 600;
                font-size: 12px;
            }}
            .price {{
                color: var(--primary);
                font-weight: 800;
            }}
            .thumb {{
                width: 34px;
                height: 34px;
                border-radius: 8px;
                object-fit: cover;
                vertical-align: middle;
                margin-right: 8px;
            }}
            .read-yes {{ color: #16A34A; font-weight: 600; font-size: 12px; }}
            .read-no {{ color: #EA580C; font-weight: 600; font-size: 12px; }}
            .text-muted {{ color: var(--text-muted); }}
            code {{
                font-family: 'JetBrains Mono', monospace;
                background: #F1F5F9;
                padding: 2px 6px;
                border-radius: 4px;
                font-size: 12px;
            }}
            .refresh-btn {{
                background: var(--primary);
                color: white;
                border: none;
                padding: 10px 16px;
                border-radius: 10px;
                font-weight: 700;
                cursor: pointer;
                display: flex;
                align-items: center;
                gap: 6px;
            }}
        </style>
    </head>
    <body>
        <div class="header">
            <div class="brand">
                <div class="logo-icon">&#127793;</div>
                <div>
                    <h1>AgriConnect Console</h1>
                    <p>Live Database Explorer (Users, Products, Orders & Messages)</p>
                </div>
            </div>
            <button class="refresh-btn" onclick="window.location.reload()">&#8635; Refresh Data</button>
        </div>

        <div class="metrics-grid">
            <div class="metric-card">
                <div class="metric-title">Registered Users</div>
                <div class="metric-value">{len(users)}</div>
            </div>
            <div class="metric-card">
                <div class="metric-title">Active Products</div>
                <div class="metric-value">{len(products)}</div>
            </div>
            <div class="metric-card">
                <div class="metric-title">Total Orders</div>
                <div class="metric-value">{len(orders)}</div>
            </div>
            <div class="metric-card">
                <div class="metric-title">Chat Messages</div>
                <div class="metric-value">{len(messages)}</div>
            </div>
        </div>

        <div class="nav-tabs">
            <button class="tab-btn active" onclick="switchTab('users', this)">&#128101; Users ({len(users)})</button>
            <button class="tab-btn" onclick="switchTab('products', this)">&#127806; Produce Listings ({len(products)})</button>
            <button class="tab-btn" onclick="switchTab('orders', this)">&#128230; Orders ({len(orders)})</button>
            <button class="tab-btn" onclick="switchTab('messages', this)">&#128172; Messages ({len(messages)})</button>
        </div>

        <!-- USERS TAB -->
        <div id="tab-users" class="tab-content active">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Phone</th>
                        <th>Location</th>
                        <th>Joined Date</th>
                    </tr>
                </thead>
                <tbody>
                    {users_rows if users_rows else '<tr><td colspan="7" style="text-align:center;padding:30px;">No users found</td></tr>'}
                </tbody>
            </table>
        </div>

        <!-- PRODUCTS TAB -->
        <div id="tab-products" class="tab-content">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Product</th>
                        <th>Category</th>
                        <th>Available Stock</th>
                        <th>Price/kg</th>
                        <th>Farmer</th>
                        <th>Farm Location</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    {products_rows if products_rows else '<tr><td colspan="8" style="text-align:center;padding:30px;">No products found</td></tr>'}
                </tbody>
            </table>
        </div>

        <!-- ORDERS TAB -->
        <div id="tab-orders" class="tab-content">
            <table>
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>Product</th>
                        <th>Quantity</th>
                        <th>Total Price</th>
                        <th>Buyer</th>
                        <th>Farmer</th>
                        <th>Status</th>
                        <th>Date Placed</th>
                    </tr>
                </thead>
                <tbody>
                    {orders_rows if orders_rows else '<tr><td colspan="8" style="text-align:center;padding:30px;">No orders found</td></tr>'}
                </tbody>
            </table>
        </div>

        <!-- MESSAGES TAB -->
        <div id="tab-messages" class="tab-content">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Sender</th>
                        <th>Receiver</th>
                        <th>Message</th>
                        <th>Sent At</th>
                        <th>Read</th>
                    </tr>
                </thead>
                <tbody>
                    {messages_rows if messages_rows else '<tr><td colspan="6" style="text-align:center;padding:30px;">No messages found</td></tr>'}
                </tbody>
            </table>
        </div>

        <script>
            function switchTab(tabName, el) {{
                document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
                document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
                el.classList.add('active');
                document.getElementById('tab-' + tabName).classList.add('active');
            }}
        </script>
    </body>
    </html>
    """
    return html_content
