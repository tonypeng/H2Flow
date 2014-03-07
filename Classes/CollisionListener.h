//
//  CollisionListener.h
//  H2Flow
//
//  Created by Tony Peng on 1/24/11.
//

#import "Box2D.h"
#import <vector>
#import <algorithm>

struct Collision {
    b2Fixture *fixtureA;
    b2Fixture *fixtureB;
    bool operator==(const Collision& other) const
    {
        return (fixtureA == other.fixtureA) && (fixtureB == other.fixtureB);
    }
};

class CollisionListener : public b2ContactListener {
	
public:
    std::vector<Collision>_contacts;
	
    CollisionListener();
    ~CollisionListener();
	
    virtual void BeginContact(b2Contact* contact);
    virtual void EndContact(b2Contact* contact);
    virtual void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);    
    virtual void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
	
};
