import ballerina/grpc;
import ballerina/io;
import ballerina/kubernetes;


map<Cart> userCarts = {};

@kubernetes:Service {

    serviceType: "ClusterIP",
    name: "cartservice"
}

@kubernetes:Deployment {
    dockerHost:"tcp://192.168.99.100:2376", 
    dockerCertPath:"/home/waruna/.minikube/certs"
}
service CartService on new grpc:Listener(7070) {

    resource function AddItem(grpc:Caller caller, AddItemRequest value) {
        string userId = value.user_id;
        Cart? cart = userCarts[userId];
        if (cart is ()) {
            CartItem[] items = [];
            cart = {user_id:userId, items:items};
            userCarts[userId] = <Cart>cart;
        }
        Cart userCart = <Cart>cart;
        userCart.items.push(value.item);
        io:println("Add item" + value.item.toString() +"for user id" + userId);
        Empty resp = {};
        var e = caller->send(resp);
        e = caller->complete();
        
    }
   resource function GetCart(grpc:Caller caller, GetCartRequest value) {
        // Implementation goes here.
        string userId = value.user_id;
        Cart? cart = userCarts[userId];
        if (cart is ()) {
            CartItem[] items = [];
            cart = {user_id:userId, items:items};
            userCarts[userId] = <Cart>cart;
        }
        Cart resp = <Cart>cart;
        io:println(resp);
        var e = caller->send(resp);
        e = caller->complete();
        // You should return a Cart
    }
    resource function EmptyCart(grpc:Caller caller, EmptyCartRequest value) {
        // Implementation goes here.
        string userId = value.user_id;
        Cart? cart = userCarts[userId];
        if (cart is Cart) {
            cart.items.removeAll();
        }
        io:println("Cart empty for user id" + userId);
        Empty resp = {};
        var e = caller->send(resp);
        e = caller->complete();
        // You should return a Empty
    }
}

