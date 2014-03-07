//
//  CollisionListener.h
//  H2Flow
//
//  Created by Tony Peng on 1/24/11.
//

#import "CollisionListener.h"

CollisionListener::CollisionListener() : _contacts() {
}

CollisionListener::~CollisionListener() {
}

void CollisionListener::BeginContact(b2Contact* contact) {
    // We need to copy out the data because the b2Contact passed in
    // is reused.
    Collision collision = { contact->GetFixtureA(), contact->GetFixtureB() };
    _contacts.push_back(collision);
}

void CollisionListener::EndContact(b2Contact* contact) {
	Collision collision = { contact->GetFixtureA(), contact->GetFixtureB() };
    std::vector<Collision>::iterator pos;
    pos = std::find(_contacts.begin(), _contacts.end(), collision);
    if (pos != _contacts.end()) {
        _contacts.erase(pos);
    }
}

void CollisionListener::PreSolve(b2Contact* contact, 
								 const b2Manifold* oldManifold) {
}

void CollisionListener::PostSolve(b2Contact* contact, 
								  const b2ContactImpulse* impulse) {
}